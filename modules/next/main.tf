resource "docker_image" "next_template_image" {
  name         = "ghcr.io/dsm23/dsm23-next-template:latest"
  keep_locally = true
}

resource "kubernetes_deployment_v1" "next_template_deployment" {
  metadata {
    name      = "next-template"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "next-template"
      }
    }

    template {
      metadata {
        labels = {
          app = "next-template"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.next_template_image.name

          port {
            container_port = 3000
            protocol       = "TCP"
            name           = "http"
          }

          startup_probe {
            http_get {
              path = "/api/health"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/api/health"
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

resource "kubernetes_service_v1" "next_template_service" {
  metadata {
    name      = "next-template-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "next-template"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.next_template_deployment.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "next_template_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "next-template-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["next.docker.localhost"]
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
          name   = "next-template-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
