resource "docker_image" "browserless_image" {
  name          = data.docker_registry_image.browserless_image.name
  pull_triggers = [data.docker_registry_image.browserless_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_deployment_v1" "browserless_deployment" {
  metadata {
    name      = "browserless"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "browserless"
      }
    }

    template {
      metadata {
        labels = {
          app = "browserless"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.browserless_image.name

          port {
            container_port = 3000
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
    name      = "browserless-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "browserless"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.browserless_deployment.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "browserless_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "browserless-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["chromium.browserless.docker.localhost"]
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
          name   = "browserless-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
