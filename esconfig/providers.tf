terraform {
  backend "gcs" {
    bucket = "BACKEND_BUCKET_NAME"
    prefix = "terraform/state/esconfig"
  }
  required_providers {
    elasticstack = {
      source = "elastic/elasticstack"
      version = "0.5.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = "ES_PASSWORD"
    endpoints = ["https://ES_IP:9200"]
    insecure = true
  }
}