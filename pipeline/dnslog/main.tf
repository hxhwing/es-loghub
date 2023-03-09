
resource "elasticstack_elasticsearch_index_template" "template" {
  name = "dnslog"

  # priority       = 42
  index_patterns = ["INDEX_PREFIX*"]
  data_stream {}

  template {
    # alias {
    #   name = "my_template_test"
    # }

    settings = jsonencode({
      # "index.routing.allocation.include._tier_preference": ["data_hot"],
      "number_of_replicas":1
    })
  }
}

data "google_storage_bucket" "bucket" {
  name = var.bucket_name
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "./src/"
  output_path = "/tmp/function-dnslog.zip"
}

resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_service_account" "sa" {
  account_id = "dnslog-gcf-sa"
}


resource "google_project_iam_member" "sa-role" {
  for_each = toset([
    "roles/pubsub.subscriber",
    "roles/pubsub.publisher",
    "roles/secretmanager.secretAccessor",
    "roles/cloudfunctions.invoker",
    "roles/run.invoker",
    "roles/storage.admin",
  ])
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project
}


resource "google_pubsub_topic" "topic" {
  name = "dnslog-topic-${random_id.suffix.hex}"
}

resource "google_pubsub_topic" "err-topic" {
  name = "dnslog-err-topic-${random_id.suffix.hex}"
}

resource "google_storage_bucket_object" "object" {
  name   = "function-dnslog-${data.archive_file.source.output_md5}.zip"
  bucket = data.google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path # Add path to the zipped function source code
}


data "google_secret_manager_secret" "es_ip" {
  secret_id = "es_ip"
}

data "google_secret_manager_secret" "es_apikey" {
  secret_id = "es_apikey"
}

resource "google_cloudfunctions2_function" "function" {
  name        = "dnslog-function-${random_id.suffix.hex}"
  location    = var.region
  description = "Function for ingest log to Elasticsearch"

  build_config {
    runtime     = "python311"
    entry_point = "pubsub_to_es" # Set the entry point
    source {
      storage_source {
        bucket = data.google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }

  service_config {
    max_instance_count               = 5
    min_instance_count               = 0
    available_memory                 = "256M"
    timeout_seconds                  = 60
    max_instance_request_concurrency = 80
    available_cpu                    = "1"
    environment_variables = {
      "error_topic" = google_pubsub_topic.err-topic.id
    }
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.sa.email
    secret_environment_variables {
      key        = "es_apikey"
      project_id = var.project
      secret     = data.google_secret_manager_secret.es_apikey.secret_id
      version    = "latest"
    }
    secret_environment_variables {
      key        = "es_ip"
      project_id = var.project
      secret     = data.google_secret_manager_secret.es_ip.secret_id
      version    = "latest"
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.topic.id
    retry_policy   = "RETRY_POLICY_RETRY"
  }

  depends_on = [google_project_iam_member.sa-role]
}


resource "google_logging_organization_sink" "sink" {
  name   = "dnslog-sink-${random_id.suffix.hex}"
  org_id = var.organization
  include_children = true

  destination = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"

  filter = "resource.type=\"dns_query\""
  exclusions {
    name = "internal-dns-log"
    filter = "jsonPayload.queryName:\"googleapis.com.\""
  }
  depends_on = [elasticstack_elasticsearch_index_template.template]
}

resource "google_project_iam_member" "log-writer" {
  project = var.project
  role    = "roles/pubsub.publisher"
  member  = google_logging_organization_sink.sink.writer_identity
}

output "dnslog-sink" {
  value = google_logging_organization_sink.sink.id
}

output "dnslog-topic" {
  value = google_pubsub_topic.topic.id
}

output "dnslog-function" {
  value = google_cloudfunctions2_function.function.id
}