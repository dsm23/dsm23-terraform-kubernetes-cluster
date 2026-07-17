variable "release_version" {
  type        = string
  default     = "3.8.2"
  description = "The version of Kyverno to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["kyverno.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
