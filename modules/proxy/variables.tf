variable "cert_manager_release_name" {
  type        = string
  default     = "cert-manager"
  description = "The name of the cert-manager Helm release."
}

variable "cert_manager_release_version" {
  type        = string
  default     = "1.20.2"
  description = "The version of cert-manager to deploy."
}

variable "proxy_gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "traefik_release_version" {
  type        = string
  default     = "40.0.0"
  description = "The version of Traefik to deploy."
}

variable "traefik_release_name" {
  type        = string
  default     = "traefik"
  description = "The name of the Traefik Helm release."
}

variable "proxy_namespace" {
  type        = string
  default     = "traefik"
  description = "The namespace where Traefik should be deployed."
}

variable "traefik_create_namespace" {
  type        = bool
  default     = true
  description = "Whether to create the Traefik namespace if it doesn't exist."
}
