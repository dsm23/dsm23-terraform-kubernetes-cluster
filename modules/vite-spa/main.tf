resource "docker_image" "vite_spa_image" {
  name         = "ghcr.io/dsm23/dsm23-vite-spa-template:latest"
  keep_locally = true
}

resource "kubernetes_deployment_v1" "vite_spa" {
  metadata {
    name      = "vite-spa"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "vite-spa"
      }
    }

    template {
      metadata {
        labels = {
          app = "vite-spa"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.vite_spa_image.name

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

resource "kubernetes_service_v1" "vite_spa_service" {
  metadata {
    name      = "vite-spa-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "vite-spa"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.vite_spa.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "vite_spa_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "vite-spa-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["vite.docker.localhost"]
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
          name   = "vite-spa-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
