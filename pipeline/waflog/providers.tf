terraform {
  backend "gcs" {
    bucket = "BACKEND_BUCKET_NAME"
    prefix = "terraform/state/pipeline/waflog"
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
  }
}

provider "google" {
  region  = var.region
  project = var.project
}