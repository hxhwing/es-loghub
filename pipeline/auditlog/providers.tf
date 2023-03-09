terraform {
  backend "gcs" {
    bucket = "BACKEND_BUCKET_NAME"
    prefix = "terraform/state/pipeline/auditlog"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
    elasticstack = {
      source = "elastic/elasticstack"
      version = "0.5.0"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project
}


provider "elasticstack" {
  elasticsearch {
    username  = "elastic"
    password  = "ES_PASSWORD"
    endpoints = ["https://ES_IP:9200"]
    insecure = true
  }
}