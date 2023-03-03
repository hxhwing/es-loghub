
# Put Elasticsearch access credentials into Secret Manager
# https://registry.terraform.io/modules/GoogleCloudPlatform/secret-manager/google/latest
module "secret-manager" {
  source  = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"
  project_id = var.project
  secrets = [
    {
      name                     = var.es_endpoint_secretname
      secret_data              = "ES_ENDPOINT"
      automatic_replication    = true
    },
    {
      name                     = var.es_password_secretname
      secret_data              = "ES_PASSWORD"
      automatic_replication    = true
    },
    {
      name                     = var.es_apikey_secretname
      secret_data              = "ES_APIKEY"
      automatic_replication    = true
    }
  ]
}