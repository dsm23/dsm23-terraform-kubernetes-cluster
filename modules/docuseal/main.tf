resource "docker_image" "docuseal_image" {
  name          = data.docker_registry_image.docuseal_image.name
  pull_triggers = [data.docker_registry_image.docuseal_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_deployment_v1" "docuseal" {
  metadata {
    name      = "docuseal"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "docuseal"
      }
    }

    template {
      metadata {
        labels = {
          app = "docuseal"
        }
      }

      spec {
        volume {
          name = "docuseal-data"
          empty_dir {} # Use persistent_volume_claim {} here for production
        }

        container {
          name  = "webapp"
          image = docker_image.docuseal_image.name

          port {
            container_port = 3000
            protocol       = "TCP"
            name           = "http"
          }

          volume_mount {
            name       = "docuseal-data"
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
    name      = "docuseal-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "docuseal"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.docuseal.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "docuseal_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "docuseal-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["docuseal.docker.localhost"]
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
          name   = "docuseal-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
