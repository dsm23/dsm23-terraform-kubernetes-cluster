locals {
  name = "headlamp"
}

resource "helm_release" "headlamp" {
  name       = local.name
  repository = "https://kubernetes-sigs.github.io/headlamp/"
  chart      = "headlamp"
  version    = var.release_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      gatewayName      = var.gateway_name
      gatewayNamespace = var.gateway_namespace
      hostnames        = var.hostnames
    })
  ]
}
