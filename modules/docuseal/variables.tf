variable "release_version" {
  type        = string
  default     = "3.0.2"
  description = "The version of docuseal to deploy."
}

variable "namespace" {
  type        = string
  description = "The namespace where docuseal should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["docuseal.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
