
# This blocks creates the Kubernetes cluster
resource "google_container_cluster" "escluster" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1
  # lifecycle {
  #   ignore_changes = [node_pool]
  # }

  networking_mode = "VPC_NATIVE"

  monitoring_config {
    managed_prometheus = "enabled"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  gke_backup_agent_config {
    enabled = true
  }
}