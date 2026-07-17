terraform {
  required_version = ">= 1.12.4"

  required_providers {
    context = {
      source  = "cloudposse/context"
      version = "0.5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
