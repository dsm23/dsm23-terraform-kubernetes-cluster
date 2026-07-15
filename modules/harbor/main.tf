locals {
  name      = "harbor"
  namespace = "harbor"
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
  namespace  = kubernetes_namespace_v1.harbor.metadata[0].name

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      gatewayName      = var.gateway_name
      gatewayNamespace = var.gateway_namespace
      hostnames        = var.hostnames
    })
  ]
}
