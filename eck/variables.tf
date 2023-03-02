variable region {
  type = string
  default = "us-central1"
}

variable "cluster_name" {
  type        = string
  description  = "GKE cluster name"
  default = "escluster"
}

variable "instance_type" {
  type        = string
  description  = "Instance type for worker node"
  default = "n2-standard-4"
}

variable "nodepool_name" {
  type        = string
  description  = "node pool name for Elasticsearch"
  default = "elasticsearch"
}

variable "node_count" {
  type        = number
  description  = "Inital node count per ZONE"
  default = 1
}