variable "release_version" {
  type        = string
  default     = "0.42.0"
  description = "The version of Headlamp to deploy."
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
  default     = ["headlamp.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
