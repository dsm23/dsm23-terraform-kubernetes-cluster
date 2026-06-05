variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of browserless to deploy."
}

variable "release_name" {
  type        = string
  default     = "browserless"
  description = "The name of the browserless Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where browserless should be deployed."
}
