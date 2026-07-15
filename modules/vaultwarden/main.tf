locals {
  name = "vaultwarden"

  container_port = 80
  host_port      = 80
}

resource "docker_image" "vaultwarden_image" {
  name          = data.docker_registry_image.vaultwarden_image.name
  pull_triggers = [data.docker_registry_image.vaultwarden_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_deployment_v1" "vaultwarden_deployment" {
  metadata {
    name      = local.name
    namespace = var.namespace
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
        container {
          name  = "webapp"
          image = docker_image.vaultwarden_image.name

          port {
            container_port = local.container_port
            protocol       = "TCP"
            name           = "http"
          }

          env {
            name  = "I_REALLY_WANT_VOLATILE_STORAGE"
            value = true
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

resource "kubernetes_service_v1" "vaultwarden_service" {
  metadata {
    name      = "${local.name}-service"
    namespace = var.namespace
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

resource "kubectl_manifest" "vaultwarden_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "${local.name}-route"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [{
        name        = var.gateway_name
        namespace   = "traefik"
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
