terraform {
  required_version = ">= 1.12.2"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.2.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
  }
}
