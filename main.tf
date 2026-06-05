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
    name = "traefik"
  }
}

locals {
  ns = kubernetes_namespace_v1.traefik_namespace.metadata[0].name
}

module "reverse_proxy" {
  source = "./modules/proxy"

  proxy_namespace = local.ns
}

module "browserless" {
  source = "./modules/browserless"

  release_namespace = module.reverse_proxy.namespace
}

module "docuseal" {
  source = "./modules/docuseal"

  release_namespace = module.reverse_proxy.namespace
}

module "next-template" {
  source = "./modules/next"

  release_namespace = module.reverse_proxy.namespace
}

module "solid-start-template" {
  source = "./modules/solid-start"

  release_namespace = module.reverse_proxy.namespace
}

module "svelte-kit-template" {
  source = "./modules/svelte-kit"

  release_namespace = module.reverse_proxy.namespace
}

module "todos-example" {
  source = "./modules/todos"

  release_namespace = module.reverse_proxy.namespace
}

module "vite-spa-template" {
  source = "./modules/vite-spa"

  release_namespace = module.reverse_proxy.namespace
}
