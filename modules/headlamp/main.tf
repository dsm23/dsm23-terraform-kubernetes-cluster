locals {
  name      = "headlamp"
  namespace = "headlamp"

  context = data.context_config.config
}

resource "kubernetes_namespace_v1" "headlamp" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "helm_release" "headlamp" {
  name       = local.name
  repository = "https://kubernetes-sigs.github.io/headlamp/"
  chart      = "headlamp"
  version    = var.release_version
  namespace  = local.namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      name      = local.context.values.gateway_name
      namespace = local.context.values.gateway_namespace
      hostnames = var.hostnames
    })
  ]
}
