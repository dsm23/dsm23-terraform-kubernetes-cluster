locals {
  name      = "docuseal"
  namespace = "docuseal"

  container_port = 3000
  host_port      = 80

  context = data.context_config.config
}

resource "docker_image" "docuseal_image" {
  name          = data.docker_registry_image.docuseal_image.name
  pull_triggers = [data.docker_registry_image.docuseal_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_namespace_v1" "docuseal" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "docuseal_pvc" {
  metadata {
    name      = "${local.name}-pvc"
    namespace = local.namespace
  }

  # k3d only
  wait_until_bound = false

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "docuseal" {
  metadata {
    name      = local.name
    namespace = local.namespace
  }

  spec {
    replicas = 1


    selector {
      match_labels = {
        app = local.name
      }
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        volume {
          name = "${local.name}-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.docuseal_pvc.metadata[0].name
          }
        }

        container {
          name  = "webapp"
          image = docker_image.docuseal_image.name

          port {
            container_port = local.container_port
            protocol       = "TCP"
            name           = "http"
          }

          volume_mount {
            name       = "${local.name}-data"
            mount_path = "/data"
          }

          startup_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "docuseal_service" {
  metadata {
    name      = "${local.name}-service"
    namespace = local.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = local.name
    }
    port {
      port        = local.host_port
      target_port = local.container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "docuseal_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "${local.name}-route"
      namespace = local.namespace
    }
    spec = {
      parentRefs = [{
        name        = local.context.values.gateway_name
        namespace   = local.context.values.gateway_namespace
        sectionName = "websecure"
      }]
      hostnames = var.hostnames
      rules = [{
        matches = [{
          path = {
            type  = "PathPrefix"
            value = "/"
          }

          filters = [
            {
              type = "ExtensionRef"
              extensionRef = {
                group = "traefik.io"
                kind  = "Middleware"
                name  = "secure-headers"
              }
            },
            {
              type = "ExtensionRef"
              extensionRef = {
                group = "traefik.io"
                kind  = "Middleware"
                name  = "ip-allowlist"
              }
            }
          ]
        }]

        backendRefs = [{
          name = "${local.name}-service"
          port = local.host_port
        }]
      }]
    }
  })
}
