
# Creating and attaching the node-pool to the Kubernetes Cluster
resource "google_container_node_pool" "node-pool" {
  name               = var.nodepool_name
  cluster            = var.cluster_name
  initial_node_count = var.node_count
  location           = var.region

  node_config {
    preemptible  = false
    machine_type = var.instance_type
    labels = {
      "app" = "elasticsearch"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count  = 1
    max_node_count  = 2
    location_policy = "BALANCED"
  }
}

