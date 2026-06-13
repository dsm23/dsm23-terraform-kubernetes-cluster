locals {
  gateway_class_name = "traefik"

  cluster_issuer_name = "selfsigned-cluster-issuer"

  issuer_name           = "selfsigned-ca-issuer"
  root_secret_name      = "root-secret"
  websecure_secret_name = "websecure-certificate-tls"

  gateway_version = "v1.6.0-rc.1"
}

data "http" "gateway_api_experimental_install" {
  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${local.gateway_version}/experimental-install.yaml"
}

locals {
  manifests = {
    for idx, manifest in data.kubectl_file_documents.gateway_api.manifests :
    idx => manifest
  }
}

data "kubectl_file_documents" "gateway_api" {
  content = data.http.gateway_api_experimental_install.response_body
}

resource "kubectl_manifest" "gateway_api" {
  for_each  = local.manifests
  yaml_body = each.value

  server_side_apply = true
}

resource "kubectl_manifest" "gateway_class" {
  depends_on = [kubectl_manifest.gateway_api]

  yaml_body = templatefile("${path.module}/templates/gatewayClass.yml.tpl", {
    gatewayClassName = local.gateway_class_name
    namespace        = var.namespace
  })
}

resource "kubectl_manifest" "gateway" {
  depends_on = [kubectl_manifest.gateway_api]

  yaml_body = templatefile("${path.module}/templates/gateway.yml.tpl", {
    gatewayClassName = local.gateway_class_name
    gatewayName      = var.gateway_name
    namespace        = var.namespace,
    secretName       = local.websecure_secret_name
  })
}

resource "helm_release" "cert_manager" {
  depends_on = [kubectl_manifest.gateway_api]

  name       = var.cert_manager_release_name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_release_version
  namespace  = var.namespace

  values = [
    yamlencode({
      crds = {
        enabled = true
      }

      config = {
        enableGatewayAPI = true
      }
    })
  ]
}


resource "kubectl_manifest" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/clusterIssuer.yml.tpl", {
    name = local.cluster_issuer_name
  })
}

resource "kubectl_manifest" "ca" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/ca.yml.tpl", {
    name              = "my-selfsigned-ca"
    namespace         = var.namespace
    commonName        = "selfsigned-ca"
    secretName        = local.root_secret_name
    clusterIssuerName = local.cluster_issuer_name
  })
}

resource "kubectl_manifest" "issuer" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/issuer.yml.tpl", {
    name       = local.issuer_name
    namespace  = var.namespace
    secretName = local.root_secret_name
  })
}

resource "kubectl_manifest" "webscure_certificate" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/certificate.yml.tpl", {
    name       = "websecure-certificate"
    namespace  = var.namespace
    secretName = local.websecure_secret_name
    dnsNames   = var.dns_names
    issuerName = local.issuer_name
  })
}

resource "kubectl_manifest" "tls_certificate" {
  depends_on = [helm_release.cert_manager]

  yaml_body = templatefile("${path.module}/templates/certificate.yml.tpl", {
    name       = "secret-tls"
    namespace  = var.namespace
    secretName = "secret-tls"
    dnsNames   = var.dns_names
    issuerName = local.issuer_name
  })
}

resource "helm_release" "traefik" {
  name       = var.traefik_release_name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.traefik_release_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/templates/values.yml.tpl", {
      namespace = var.namespace,
    })
  ]
}

resource "kubectl_manifest" "middleware" {
  depends_on = [helm_release.traefik]

  yaml_body = templatefile("${path.module}/templates/middleware.yml.tpl", {
    namespace = var.namespace
  })
}
