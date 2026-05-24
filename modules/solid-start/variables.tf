variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of solid-start to deploy."
}

variable "release_name" {
  type        = string
  default     = "solid-start"
  description = "The name of the solid-start Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where solid-start should be deployed."
}
