variable "release_version" {
  type        = string
  default     = "1.19.1"
  description = "The version of Harbor to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["harbor.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
