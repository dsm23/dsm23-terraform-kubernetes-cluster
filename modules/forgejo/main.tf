locals {
  name = "forgejo"
}

resource "helm_release" "forgejo" {
  name       = local.name
  repository = "oci://code.forgejo.org/forgejo-helm"
  chart      = "forgejo"
  version    = var.release_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      gatewayName = var.gateway_name
      hostnames   = var.hostnames
    })
  ]
}
