
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


resource "elasticstack_elasticsearch_index_template" "template" {
  name = "httplog"

  # priority       = 42
  index_patterns = ["INDEX_PREFIX*", "log-*"]

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

output "password" {
  value = random_password.password.result
  sensitive = true
}

