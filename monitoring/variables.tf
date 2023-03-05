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
