variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of vite-spa to deploy."
}

variable "release_name" {
  type        = string
  default     = "vite-spa"
  description = "The name of the vite-spa Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where vite-spa should be deployed."
}
