locals {
  name      = "kyverno"
  namespace = "kyverno"

  context = data.context_config.config
}

resource "kubernetes_namespace_v1" "kyverno" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "helm_release" "kyverno" {
  name       = local.name
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno"
  version    = var.release_version
  namespace  = kubernetes_namespace_v1.kyverno.metadata[0].name
}

resource "kubectl_manifest" "environment_label_policy" {
  depends_on = [helm_release.kyverno]

  yaml_body = templatefile("${path.module}/templates/validatingPolicy.yml.tpl", {
    namespace = local.context.values.apps_namespace
  })
}
