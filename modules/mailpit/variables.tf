variable "release_version" {
  type        = string
  default     = "v1.30.1"
  description = "The version of mailpit to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where mailpit should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["mailpit.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
