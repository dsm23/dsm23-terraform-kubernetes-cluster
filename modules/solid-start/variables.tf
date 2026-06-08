variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of solid-start to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where solid-start should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["solid.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
