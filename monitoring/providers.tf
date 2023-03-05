terraform {
  backend "gcs" {
    bucket = "BACKEND_BUCKET_NAME"
    prefix = "terraform/state/monitoring"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.55.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}

provider "google" {
  region  = var.region
  project = var.project
}

data "google_client_config" "default" {}

# Import existing cluster
data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
  load_config_file = "false"
}



