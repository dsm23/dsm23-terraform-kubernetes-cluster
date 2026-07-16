variable "cert_manager_release_name" {
  type        = string
  default     = "cert-manager"
  description = "The name of the cert-manager Helm release"
}

variable "cert_manager_release_version" {
  type        = string
  default     = "1.20.3"
  description = "The version of cert-manager to deploy"
}

variable "dns_names" {
  type        = list(string)
  default     = ["*.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}

variable "traefik_release_version" {
  type        = string
  default     = "41.0.1"
  description = "The version of Traefik to deploy"
}

variable "traefik_release_name" {
  type        = string
  default     = "traefik"
  description = "The name of the Traefik Helm release"
}
