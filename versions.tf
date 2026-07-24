terraform {
  required_version = ">= 1.12.5"

  required_providers {
    context = {
      source  = "cloudposse/context"
      version = "0.5.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "4.2.0"
    }

    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.62.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }

    k3d = {
      source  = "SneakyBugs/k3d"
      version = "1.0.1"
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
