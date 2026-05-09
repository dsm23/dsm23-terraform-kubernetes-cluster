variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of next to deploy."
}

variable "release_name" {
  type        = string
  default     = "next"
  description = "The name of the next Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where next should be deployed."
}
