locals {
  name      = "browserless"
  namespace = "browserless"

  container_port = 3000
  host_port      = 80

  context = data.context_config.config
}

resource "docker_image" "browserless_image" {
  name          = data.docker_registry_image.browserless_image.name
  pull_triggers = [data.docker_registry_image.browserless_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_namespace_v1" "browserless" {
  metadata {
    name = local.namespace
    labels = {
      gateway-access = "true"
    }
  }
}

resource "kubernetes_deployment_v1" "browserless_deployment" {
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
        container {
          name  = "webapp"
          image = docker_image.browserless_image.name

          port {
            container_port = local.container_port
            protocol       = "TCP"
            name           = "http"
          }

          startup_probe {
            http_get {
              path = "/docs"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/docs"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/docs"
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

resource "kubernetes_service_v1" "browserless_service" {
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

resource "kubectl_manifest" "browserless_route" {
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
