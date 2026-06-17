variable "namespace" {
  type        = string
  default     = "traefik"
  description = "The namespace where KEDA should be deployed"
}

variable "release_version" {
  type        = string
  default     = "2.20.1"
  description = "The version of KEDA to deploy."
}

variable "release_version_http_addons" {
  type        = string
  default     = "0.15.0"
  description = "The version of KEDA http-addons to deploy."
}
