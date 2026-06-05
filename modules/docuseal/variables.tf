variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of docuseal to deploy."
}

variable "release_name" {
  type        = string
  default     = "docuseal"
  description = "The name of the docuseal Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where docuseal should be deployed."
}
