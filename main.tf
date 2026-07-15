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
  namespace    = "traefik"
}

resource "kubernetes_namespace_v1" "apps" {
  metadata {
    name = "apps"
    labels = {
      gateway-access = "true"
    }
  }
}

module "reverse_proxy" {
  source = "./modules/proxy"

  gateway_name = local.gateway_name
  namespace    = local.namespace
}

module "keda" {
  depends_on = [module.reverse_proxy]

  source    = "./modules/keda"
  namespace = local.namespace
}

module "browserless" {
  depends_on = [module.keda]

  source = "./modules/browserless"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "docuseal" {
  depends_on = [module.keda]

  source = "./modules/docuseal"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "dozzle" {
  depends_on = [module.keda]

  source = "./modules/dozzle"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "forgejo" {
  depends_on = [module.keda]

  source = "./modules/forgejo"

  gateway_name      = local.gateway_name
  gateway_namespace = local.namespace
  namespace         = kubernetes_namespace_v1.apps.metadata[0].name
}

module "harbor" {
  depends_on = [module.keda]

  source = "./modules/harbor"

  gateway_name      = local.gateway_name
  gateway_namespace = local.namespace
  namespace         = kubernetes_namespace_v1.apps.metadata[0].name
}

module "headlamp" {
  depends_on = [module.keda]

  source = "./modules/headlamp"

  gateway_name      = local.gateway_name
  gateway_namespace = local.namespace
  namespace         = kubernetes_namespace_v1.apps.metadata[0].name
}

module "mailpit" {
  depends_on = [module.keda]

  source = "./modules/mailpit"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "next-template" {
  depends_on = [module.keda]

  source = "./modules/next"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "openbao" {
  depends_on = [module.keda]

  source = "./modules/openbao"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "solid-start-template" {
  depends_on = [module.keda]

  source = "./modules/solid-start"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "svelte-kit-template" {
  depends_on = [module.keda]

  source = "./modules/svelte-kit"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "todos-example" {
  depends_on = [module.keda]

  source = "./modules/todos"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "vaultwarden" {
  depends_on = [module.keda]

  source = "./modules/vaultwarden"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "vite-spa-template" {
  depends_on = [module.keda]

  source = "./modules/vite-spa"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}

module "totally-not-xss-vulnerable" {
  depends_on = [module.keda]

  source = "./modules/xss"

  gateway_name = local.gateway_name
  namespace    = kubernetes_namespace_v1.apps.metadata[0].name
}
