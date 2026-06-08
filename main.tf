data "docker_registry_image" "k3s_image" {
  name = "rancher/k3s:${var.k3s_version}"
}

resource "docker_image" "k3s_image" {
  name          = data.docker_registry_image.k3s_image.name
  pull_triggers = [data.docker_registry_image.k3s_image.sha256_digest]

  keep_locally = true
}

resource "k3d_cluster" "k3d" {
  name = "local-cluster"

  k3d_config = templatefile("${path.module}/templates/localClusterConfig.yml.tpl",
  { cluster_image = docker_image.k3s_image.name })
}

locals {
  gateway_name = "traefik-gateway"
  namespace    = "production"
}

resource "kubernetes_namespace_v1" "traefik_namespace" {
  metadata {
    name = local.namespace
  }
}

module "reverse_proxy" {
  source = "./modules/proxy"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "browserless" {
  source = "./modules/browserless"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "docuseal" {
  source = "./modules/docuseal"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "mailpit" {
  source = "./modules/mailpit"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "next-template" {
  source = "./modules/next"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "solid-start-template" {
  source = "./modules/solid-start"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "svelte-kit-template" {
  source = "./modules/svelte-kit"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "todos-example" {
  source = "./modules/todos"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "vaultwarden" {
  source = "./modules/vaultwarden"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "vite-spa-template" {
  source = "./modules/vite-spa"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}
