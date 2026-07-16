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
}

module "keda" {
  depends_on = [module.reverse_proxy]

  source = "./modules/keda"
}

module "browserless" {
  depends_on = [module.keda]

  source = "./modules/browserless"
}

module "docuseal" {
  depends_on = [module.keda]

  source = "./modules/docuseal"
}

module "dozzle" {
  depends_on = [module.keda]

  source = "./modules/dozzle"
}

module "forgejo" {
  depends_on = [module.keda]

  source = "./modules/forgejo"
}

module "harbor" {
  depends_on = [module.keda]

  source = "./modules/harbor"
}

module "headlamp" {
  depends_on = [module.keda]

  source = "./modules/headlamp"
}

module "mailpit" {
  depends_on = [module.keda]

  source = "./modules/mailpit"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "next-template" {
  depends_on = [module.keda]

  source = "./modules/next"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "openbao" {
  depends_on = [module.keda]

  source = "./modules/openbao"
}

module "solid-start-template" {
  depends_on = [module.keda]

  source = "./modules/solid-start"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "svelte-kit-template" {
  depends_on = [module.keda]

  source = "./modules/svelte-kit"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "todos-example" {
  depends_on = [module.keda]

  source = "./modules/todos"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "vaultwarden" {
  depends_on = [module.keda]

  source = "./modules/vaultwarden"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "vite-spa-template" {
  depends_on = [module.keda]

  source = "./modules/vite-spa"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}

module "totally-not-xss-vulnerable" {
  depends_on = [module.keda]

  source = "./modules/xss"

  namespace = kubernetes_namespace_v1.apps.metadata[0].name
}
