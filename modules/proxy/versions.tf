terraform {
  required_version = ">= 1.12.2"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.6.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}
