variable "release_version" {
  type        = string
  default     = "0.28.3"
  description = "The version of OpenBao to deploy."
}

variable "hostnames" {
  type        = list(string)
  default     = ["openbao.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
