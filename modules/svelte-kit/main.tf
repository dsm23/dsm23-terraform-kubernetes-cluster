resource "docker_image" "svelte_kit_image" {
  name         = "ghcr.io/dsm23/dsm23-svelte-kit-template:latest"
  keep_locally = true
}

resource "kubernetes_deployment_v1" "svelte_kit" {
  metadata {
    name      = "svelte-kit"
    namespace = var.release_namespace
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "svelte-kit"
      }
    }

    template {
      metadata {
        labels = {
          app = "svelte-kit"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.svelte_kit_image.name

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

resource "kubernetes_service_v1" "svelte_kit_service" {
  metadata {
    name      = "svelte-kit-service"
    namespace = var.release_namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "svelte-kit"
    }
    port {
      port        = 80
      target_port = kubernetes_deployment_v1.svelte_kit.spec[0].template[0].spec[0].container[0].port[0].container_port
      protocol    = "TCP"
    }
  }
}

resource "kubectl_manifest" "svelte_kit_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "svelte-kit-route"
      namespace = var.release_namespace
    }
    spec = {
      parentRefs = [{
        name = "traefik-gateway"
      }]
      hostnames = ["svelte.docker.localhost"]
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
          name   = "svelte-kit-service"
          port   = 80
          weight = 1
        }]
      }]
    }
  })
}
