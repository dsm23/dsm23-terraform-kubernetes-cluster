variable "release_version" {
  type        = string
  default     = "v10.6.5"
  description = "The version of Dozzle to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["dozzle.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
