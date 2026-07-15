variable "release_version" {
  type        = string
  default     = "17.1.1"
  description = "The version of Forgejo to deploy."
}

variable "gateway_name" {
  type        = string
  description = "The gateway name in the reverse proxy."
}

variable "gateway_namespace" {
  type        = string
  description = "The gateway namespace in the reverse proxy."
}

variable "namespace" {
  type        = string
  description = "The namespace where next should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["forgejo.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
