variable "release_version" {
  type        = string
  default     = "17.1.1"
  description = "The version of Forgejo to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["forgejo.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
