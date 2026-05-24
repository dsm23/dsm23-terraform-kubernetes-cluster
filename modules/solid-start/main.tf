resource "docker_image" "solid_start_image" {
  name         = "ghcr.io/dsm23/dsm23-solid-start-template:latest"
  keep_locally = true
}

resource "kubernetes_deployment_v1" "solid_start" {
  metadata {
    name      = "solid-start"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "solid-start"
      }
    }

    template {
      metadata {
        labels = {
          app = "solid-start"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.solid_start_image.name

          port {
            container_port = 3000
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

resource "kubernetes_service_v1" "solid_start_service" {
  metadata {
    name      = "solid-start-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "solid-start"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.solid_start.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "solid_start_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "solid-start-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["solid.docker.localhost"]
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
          name   = "solid-start-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
