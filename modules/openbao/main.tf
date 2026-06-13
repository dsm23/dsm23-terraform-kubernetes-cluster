locals {
  name = "openbao"

  container_port = 8200
  host_port      = 8200
}

resource "helm_release" "openbao" {
  name       = local.name
  repository = "https://openbao.github.io/openbao-helm"
  chart      = "openbao"
  version    = var.release_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {

    })
  ]
}

resource "kubectl_manifest" "openbao_route" {
  depends_on = [helm_release.openbao]

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "TLSRoute"
    metadata = {
      name      = "${local.name}-route"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [{
        name        = var.gateway_name
        sectionName = "tls-passthrough"
      }]
      hostnames = var.hostnames
      rules = [{
        backendRefs = [{
          name      = "openbao-active"
          namespace = var.namespace
          port      = local.host_port
        }]
      }]
    }
  })
}
