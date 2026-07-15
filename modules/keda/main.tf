locals {
  namespace = "keda"
}

resource "helm_release" "keda_core" {
  name             = "keda"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda"
  version          = var.release_version
  namespace        = local.namespace
  create_namespace = true
}

resource "helm_release" "keda_http_addons" {
  depends_on = [helm_release.keda_core]

  name             = "keda-add-ons-http"
  repository       = "https://kedacore.github.io/charts"
  chart            = "keda-add-ons-http"
  version          = var.release_version_http_addons
  namespace        = local.namespace
  create_namespace = true
}

resource "kubectl_manifest" "reference_grant" {
  depends_on = [helm_release.keda_core]

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "ReferenceGrant"
    metadata = {
      name      = "allow-httproute-to-interceptor"
      namespace = local.namespace
    }
    spec = {
      from = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "HTTPRoute"
          namespace = var.namespace
        },
        {
          group = "gateway.networking.k8s.io"
          kind  = "HTTPRoute"
          # TODO: remove hard-coding
          namespace = "apps"
        }
      ]
      to = [
        {
          group = ""
          kind  = "Service"
          name  = "keda-add-ons-http-interceptor-proxy"
        }
      ]
    }
  })
}
