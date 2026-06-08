variable "release_version" {
  type        = string
  default     = "1.36.0-alpine"
  description = "The version of vaultwarden to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where vaultwarden should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["vaultwarden.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
