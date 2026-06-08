variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of next to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where next should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["next.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
