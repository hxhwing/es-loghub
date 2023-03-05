variable "region" {
  type    = string
  default = "REGION_ID"
}

variable "project" {
  type    = string
  default = "PROJECT_ID"
}

variable "es_endpoint_secretname" {
  type    = string
  default = "es_ip"
}

variable "es_password_secretname" {
  type    = string
  default = "es_password"
}

variable "es_apikey_secretname" {
  type    = string
  default = "es_apikey"
}