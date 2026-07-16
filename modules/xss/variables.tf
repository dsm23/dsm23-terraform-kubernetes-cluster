variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of totally-not-xss-vulnerable to deploy."
}

variable "namespace" {
  type        = string
  description = "The namespace where totally-not-xss-vulnerable should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["xss.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
