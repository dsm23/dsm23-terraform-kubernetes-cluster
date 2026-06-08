variable "release_version" {
  type        = string
  default     = "v2.51.0"
  description = "The version of browserless to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where browserless should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["chromium.browserless.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
