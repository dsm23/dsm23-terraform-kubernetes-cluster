locals {
  secret_name = "local-selfsigned-tls"
}

resource "helm_release" "cert_manager" {
  name       = var.cert_manager_release_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_release_version
  namespace  = var.namespace

  values = [
    yamlencode({
      installCRDs = true
    })
  ]
}

resource "helm_release" "traefik" {
  name       = var.traefik_release_name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.traefik_release_version
  namespace  = var.namespace
  # create_namespace = var.traefik_create_namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      gatewayName = var.gateway_name
      namespace   = var.namespace,
      secretName  = local.secret_name
    })
  ]
}

resource "kubectl_manifest" "middleware" {
  depends_on = [helm_release.traefik]

  yaml_body = templatefile("${path.module}/templates/middleware.yml.tpl", {
    namespace = var.namespace
  })
}

resource "kubectl_manifest" "issuer" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/issuer.yml.tpl", {
    namespace = var.namespace
  })
}

resource "kubectl_manifest" "certificate" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/certificate.yml.tpl", {
    namespace  = var.namespace,
    secretName = local.secret_name
  })
}
