variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of svelte-kit to deploy."
}

variable "release_name" {
  type        = string
  default     = "svelte-kit"
  description = "The name of the svelte-kit Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where svelte-kit should be deployed."
}
