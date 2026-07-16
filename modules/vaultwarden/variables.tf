variable "release_version" {
  type        = string
  default     = "1.36.0-alpine"
  description = "The version of vaultwarden to deploy."
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
