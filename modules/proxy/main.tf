resource "helm_release" "cert_manager" {
  name       = var.cert_manager_release_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_release_version
  namespace  = var.proxy_namespace

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
  namespace  = var.proxy_namespace
  # create_namespace = var.traefik_create_namespace

  values = [
    templatefile("${path.module}/values.yml", {})
  ]
}

resource "kubectl_manifest" "middleware" {
  depends_on = [helm_release.traefik]

  yaml_body = templatefile("${path.module}/middleware.yml.tpl", {
    namespace = var.proxy_namespace
  })
}

resource "kubectl_manifest" "issuer" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/issuer.yml.tpl", {
    namespace = var.proxy_namespace
  })
}

resource "kubectl_manifest" "certificate" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/certificate.yml.tpl", {
    namespace  = var.proxy_namespace,
    secretName = "whoami-tls-le"
  })
}
