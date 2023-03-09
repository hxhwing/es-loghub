
resource "random_password" "password" {
  length           = 8
  special          = false
}


resource "elasticstack_elasticsearch_security_api_key" "api_key" {
  # Set the name
  name = "admin-key"
  role_descriptors = jsonencode({})
}


resource "elasticstack_elasticsearch_security_user" "monitor" {
  username = "monitor"
  password = random_password.password.result
  roles    = ["remote_monitoring_collector"]

  metadata = jsonencode({})
}


resource "elasticstack_elasticsearch_index_template" "auditlog_template" {
  name = "auditlog"

  # priority       = 42
  index_patterns = ["AUDITLOG_INDEX_PREFIX*"]
  data_stream {}

  template {
    # alias {
    #   name = "my_template_test"
    # }

    settings = jsonencode({
      # "index.routing.allocation.include._tier_preference": ["data_hot"],
      # "index.routing.allocation.include.data": "hot",
      "number_of_replicas":1
    })
  }
}

resource "elasticstack_elasticsearch_index_template" "dnslog_template" {
  name = "dnslog"

  # priority       = 42
  index_patterns = ["DNSLOG_INDEX_PREFIX*"]
  data_stream {}

  template {
    # alias {
    #   name = "my_template_test"
    # }

    settings = jsonencode({
      # "index.routing.allocation.include._tier_preference": ["data_hot"],
      # "index.routing.allocation.include.data": "hot",
      "number_of_replicas":1
    })
  }
}

resource "elasticstack_elasticsearch_index_template" "httplog_template" {
  name = "httplog"

  # priority       = 42
  index_patterns = ["HTTPLOG_INDEX_PREFIX*"]
  data_stream {}

  template {
    # alias {
    #   name = "my_template_test"
    # }

    settings = jsonencode({
      # "index.routing.allocation.include._tier_preference": ["data_hot"],
      # "index.routing.allocation.include.data": "hot",
      "number_of_replicas":1
    })
    mappings = jsonencode({
      properties : {
        "geoip": {
            "properties": {
              "location":{"type": "geo_point"}
            }
        }
      }
    })
  }
}


output "api_key" {
  value     = elasticstack_elasticsearch_security_api_key.api_key.encoded
  sensitive = true
}

output "password" {
  value = random_password.password.result
  sensitive = true
}

