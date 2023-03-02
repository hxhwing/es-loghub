terraform {
  backend "gcs" {
    bucket  = "BACKEND_BUCKET_NAME"
    prefix  = "terraform/state/eck"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.55.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.18.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.9.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}

provider "google" {
  region      = var.region
  project     = var.project
}

data "google_client_config" "default" {}

# Import existing cluster
data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.region
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.cluster.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
    )
  }
}

provider "kubectl" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  client_certificate     = base64decode(data.google_container_cluster.cluster.master_auth.0.client_certificate)
  client_key             = base64decode(data.google_container_cluster.cluster.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
}

# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.cluster.endpoint}"
# #  config_path    = "~/.kube/config"

#   client_certificate     = base64decode(data.google_container_cluster.cluster.master_auth.0.client_certificate)
#   client_key             = base64decode(data.google_container_cluster.cluster.master_auth.0.client_key)
#   cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
# }

# provider "kubernetes" {
#   host  = "https://${data.google_container_cluster.cluster.endpoint}"
#   token = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(
#     data.google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
#   )
# }


