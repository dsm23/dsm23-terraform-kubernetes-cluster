locals {
  name      = "forgejo"
  namespace = "forgejo"

  context = data.context_config.config
}

resource "kubernetes_namespace_v1" "forgejo" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "helm_release" "forgejo" {
  name       = local.name
  repository = "oci://code.forgejo.org/forgejo-helm"
  chart      = "forgejo"
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
