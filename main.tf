resource "docker_image" "k3s" {
  name         = "rancher/k3s:v1.36.0-k3s1"
  keep_locally = true
}

resource "k3d_cluster" "k3d" {
  name = "local-cluster"

  k3d_config = templatefile("${path.module}/localClusterConfig.yml.tpl", { cluster_image = docker_image.k3s.name })
}

resource "kubernetes_namespace_v1" "traefik_namespace" {
  metadata {
    name = "production"
  }
}

locals {
  ns = kubernetes_namespace_v1.traefik_namespace.metadata[0].name

  gateway_name = "traefik-gateway"
}

module "reverse_proxy" {
  source = "./modules/proxy"

  proxy_gateway_name = local.gateway_name
  proxy_namespace    = local.ns
}

module "browserless" {
  source = "./modules/browserless"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "docuseal" {
  source = "./modules/docuseal"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "mailpit" {
  source = "./modules/mailpit"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "next-template" {
  source = "./modules/next"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "solid-start-template" {
  source = "./modules/solid-start"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "svelte-kit-template" {
  source = "./modules/svelte-kit"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "todos-example" {
  source = "./modules/todos"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "vaultwarden" {
  source = "./modules/vaultwarden"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}

module "vite-spa-template" {
  source = "./modules/vite-spa"

  gateway_name = local.gateway_name
  namespace    = module.reverse_proxy.namespace
}
