variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of svelte-kit to deploy."
}

variable "namespace" {
  type        = string
  description = "The namespace where svelte-kit should be deployed."
}

variable "hostnames" {
  type        = list(string)
  default     = ["svelte.docker.localhost"]
  description = "The hostnames supplied to Kubernetes Gateway"
}
