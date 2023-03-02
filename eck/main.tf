
# Creating and attaching the node-pool to the Kubernetes Cluster
resource "google_container_node_pool" "node-pool" {
  name               = var.nodepool_name
  cluster            = var.cluster_name
  initial_node_count = var.node_count

  node_config {
    preemptible  = false
    machine_type = var.instance_type
    labels = {
      "app"                     = "elasticsearch"
    }
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 2
    location_policy = "BALANCED"
  }
}

# Create the cluster role binding to give the user the privileges to create resources into Kubernetes
# resource "kubernetes_cluster_role_binding" "cluster-admin-binding" {
#   metadata {
#     name = "cluster-role-binding"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "User"
#     name      = "${var.email}"
#     api_group = "rbac.authorization.k8s.io"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = "default"
#     namespace = "kube-system"
#   }
#   subject {
#     kind      = "Group"
#     name      = "system:masters"
#     api_group = "rbac.authorization.k8s.io"
#   }

#   depends_on = [google_container_cluster.escluster, google_container_node_pool.node-pool]
# }

# Install ECK operator via helm-charts
resource "helm_release" "elastic" {
  name = "elastic-operator"

  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  namespace        = "elastic-system"
  create_namespace = "true"

  depends_on = [google_container_cluster.escluster, google_container_node_pool.node-pool]

}


# Delay of 30s to wait until ECK operator is up and running
resource "time_sleep" "sleep30s" {
  depends_on = [helm_release.elastic]

  create_duration = "30s"
}


data "kubectl_file_documents" "sc" {
    content = file("eck/manifests/storageclass.yaml")
}

resource "kubectl_manifest" "storageclass" {
  for_each  = data.kubectl_file_documents.sc.manifests
  yaml_body = each.value
  depends_on = [google_container_cluster.escluster, google_container_node_pool.node-pool]
}

data "kubectl_file_documents" "es" {
    content = file("eck/manifests/elasticsearch.yaml")
}

# Deploy Elasticsearch 
resource "kubectl_manifest" "elasticsearch" {
  for_each  = data.kubectl_file_documents.es.manifests
  yaml_body = each.value
  depends_on = [helm_release.elastic, kubectl_manifest.storageclass, time_sleep.sleep30s]
  provisioner "local-exec" {
     command = "sleep 30"
  }
}

data "kubectl_file_documents" "kb" {
    content = file("eck/manifests/kibana.yaml")
}

# Deploy Kibana 
resource "kubectl_manifest" "kibana" {
  for_each  = data.kubectl_file_documents.kb.manifests
  yaml_body = each.value
  depends_on = [helm_release.elastic, kubectl_manifest.elasticsearch]
  provisioner "local-exec" {
     command = "sleep 30"
  }
}



# resource "kubernetes_manifest" "elasticsearch" {
#   manifest = yamldecode(file("eck/elasticsearch.yaml"))
# }

# resource "kubernetes_manifest" "kibana" {
#   manifest = yamldecode(file("eck/kibana.yaml"))
# }