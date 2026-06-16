terraform {
  required_version = ">= 1.12.2"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}
