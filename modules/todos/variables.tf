variable "release_version" {
  type        = string
  default     = "latest"
  description = "The version of todos to deploy."
}

variable "release_name" {
  type        = string
  default     = "todos"
  description = "The name of the todos Helm release."
}

variable "release_namespace" {
  type        = string
  description = "The namespace where todos should be deployed."
}
