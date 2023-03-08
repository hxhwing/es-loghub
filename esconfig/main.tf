terraform {
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
      version = "0.5.0"
    }
  }
}

provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = "ES_PASSWORD"
    endpoints = ["ES_ENDPOINT"]
    insecure = true
  }
}


resource "elasticstack_elasticsearch_security_api_key" "api_key" {
  # Set the name
  name = "admin-key"
  role_descriptors = jsonencode({})
}


resource "elasticstack_elasticsearch_security_user" "monitor" {
  username = "monitor"
  password = "Prometheus"
  roles    = ["remote_monitoring_collector"]

  metadata = jsonencode({})
}


resource "elasticstack_elasticsearch_index_template" "template" {
  name = "httplog"

  # priority       = 42
  index_patterns = ["INDEX_PREFIX*"]

  template {
    # alias {
    #   name = "my_template_test"
    # }

    settings = jsonencode({
      "index.routing.allocation.include.data": "hot"
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
