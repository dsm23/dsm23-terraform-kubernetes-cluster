variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of todos to deploy."
}

variable "namespace" {
  type        = string
  description = "The namespace where todos should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["todos.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
