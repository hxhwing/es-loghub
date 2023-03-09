
# Craete service account for Elasticsearch Workload Identity
resource "google_service_account" "sa" {
  account_id   = "elasticsearch-sa"
  display_name = "elasticsearch-sa"
}


resource "google_project_iam_member" "sa-role" {
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project
}

resource "google_service_account_iam_binding" "sa-user" {
  service_account_id = google_service_account.sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/elasticsearch-sa]",
  ]
}

# Create kubernetes service account for elasticsearch
data "kubectl_file_documents" "es-sa" {
  content = file("manifests/es-sa.yaml")
}

resource "kubectl_manifest" "es-sa" {
  for_each   = data.kubectl_file_documents.es-sa.manifests
  yaml_body  = each.value
  depends_on = [google_service_account_iam_binding.sa-user, kubectl_manifest.elasticsearch]
}



# Install ECK operator via helm-charts
resource "helm_release" "elastic" {
  name = "elastic-operator"

  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  namespace        = "elastic-system"
  create_namespace = "true"
}


# Delay of 30s to wait until ECK operator is up and running
resource "time_sleep" "sleep10s" {
  depends_on = [helm_release.elastic]

  create_duration = "10s"
}


data "kubectl_file_documents" "sc" {
  content = file("manifests/storageclass.yaml")
}

resource "kubectl_manifest" "storageclass" {
  for_each  = data.kubectl_file_documents.sc.manifests
  yaml_body = each.value
}

data "kubectl_file_documents" "es" {
  content = file("manifests/elasticsearch.yaml")
}

# Deploy Elasticsearch 
resource "kubectl_manifest" "elasticsearch" {
  for_each   = data.kubectl_file_documents.es.manifests
  yaml_body  = each.value
  depends_on = [helm_release.elastic, kubectl_manifest.storageclass, time_sleep.sleep10s]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

data "kubectl_file_documents" "kb" {
  content = file("manifests/kibana.yaml")
}

# Deploy Kibana 
resource "kubectl_manifest" "kibana" {
  for_each   = data.kubectl_file_documents.kb.manifests
  yaml_body  = each.value
  depends_on = [helm_release.elastic, kubectl_manifest.elasticsearch]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}



# resource "kubernetes_manifest" "elasticsearch" {
#   manifest = yamldecode(file("eck/elasticsearch.yaml"))
# }

# resource "kubernetes_manifest" "kibana" {
#   manifest = yamldecode(file("eck/kibana.yaml"))
# }
