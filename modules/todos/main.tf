resource "docker_image" "todos_image" {
  name         = "ghcr.io/dsm23/todomvc-redux-example:latest"
  keep_locally = true
}

resource "kubernetes_deployment_v1" "todos" {
  metadata {
    name      = "todos"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "todos"
      }
    }

    template {
      metadata {
        labels = {
          app = "todos"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.todos_image.name

          port {
            container_port = 80
            protocol       = "TCP"
            name           = "http"
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

resource "kubernetes_service_v1" "todos_service" {
  metadata {
    name      = "todos-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "todos"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.todos.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "todos_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "todos-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["todos.docker.localhost"]
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
          name   = "todos-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
