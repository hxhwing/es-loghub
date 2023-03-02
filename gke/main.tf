
# This blocks creates the Kubernetes cluster
resource "google_container_cluster" "escluster" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1
  # lifecycle {
  #   ignore_changes = [node_pool]
  # }
}