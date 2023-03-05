
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
    enable_components: ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  addons_config {
    gke_backup_agent_config {
      enabled = true
    }
  }
}