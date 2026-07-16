variable "release_version" {
  type        = string
  default     = "0.42.0"
  description = "The version of Headlamp to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["headlamp.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
