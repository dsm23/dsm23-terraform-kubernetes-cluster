variable "release_version" {
  type        = string
  default     = "3.0.2"
  description = "The version of docuseal to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["docuseal.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
