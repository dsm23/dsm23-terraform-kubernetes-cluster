variable "release_version" {
  type        = string
  default     = "v10.6.5"
  description = "The version of Dozzle to deploy."
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
  default     = ["dozzle.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
