variable "region" {
  type    = string
  default = "REGION_ID"
}

variable "project" {
  type    = string
  default = "PROJECT_ID"
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
  default     = "CLUSTER_NAME"
}

variable "instance_type" {
  type        = string
  description = "Instance type for worker node"
  default     = "INSTANCE_TYPE"
}

variable "nodepool_name" {
  type        = string
  description = "node pool name for Elasticsearch"
  default     = "es-nodepool"
}

variable "node_count" {
  type        = number
  description = "Inital node count per ZONE"
  default     = INITIAL_NODE_COUNT
}