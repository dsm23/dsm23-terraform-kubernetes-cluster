terraform {
  required_version = ">= 1.12.6"

  required_providers {
    context = {
      source  = "cloudposse/context"
      version = "0.5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
}
