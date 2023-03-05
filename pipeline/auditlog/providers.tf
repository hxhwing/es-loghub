terraform {
  # backend "gcs" {
  #   bucket = "BACKEND_BUCKET_NAME"
  #   prefix = "terraform/state/pipeline/audit"
  # }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project
}