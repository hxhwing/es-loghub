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
  description = "Please, enter your GKE cluster name"
  default     = "NEW_CLUSTER_NAME"
}