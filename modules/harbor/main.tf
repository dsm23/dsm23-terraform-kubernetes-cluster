locals {
  name      = "harbor"
  namespace = "harbor"

  context = data.context_config.config
}

resource "kubernetes_namespace_v1" "harbor" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "helm_release" "harbor" {
  name       = local.name
  repository = "https://helm.goharbor.io"
  chart      = "harbor"
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
