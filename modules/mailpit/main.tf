locals {
  name = "mailpit"

  container_port = 8025
  host_port      = 80

  smtp_container_port = 1025
  smtp_host_port      = 1025

  context = data.context_config.config
}

resource "docker_image" "mailpit_image" {
  name          = data.docker_registry_image.mailpit_image.name
  pull_triggers = [data.docker_registry_image.mailpit_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_deployment_v1" "mailpit" {
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
          app         = local.name
          environment = "production"
        }
      }

      spec {
        container {
          name  = "webapp"
          image = docker_image.mailpit_image.name

          port {
            container_port = local.container_port
            protocol       = "TCP"
            name           = "http"
          }

          port {
            container_port = local.smtp_container_port
            protocol       = "TCP"
            name           = "smtp"
          }

          env {
            name  = "MP_SMTP_AUTH_ACCEPT_ANY"
            value = 1
          }

          env {
            name  = "MP_SMTP_AUTH_ALLOW_INSECURE"
            value = 1
          }

          env {
            name  = "TZ"
            value = "Europe / London"
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
              path = "/livez"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/readyz"
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

resource "kubernetes_service_v1" "mailpit" {
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
      name        = "http"
      port        = local.host_port
      target_port = local.container_port
      protocol    = "TCP"
    }

    port {
      name         = "smtp"
      port         = local.smtp_host_port
      target_port  = local.smtp_container_port
      protocol     = "TCP"
      app_protocol = "tcp"
    }
  }
}

resource "kubectl_manifest" "mailpit_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "${local.name}-route"
      namespace = var.namespace
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

resource "kubectl_manifest" "mailpit_smtp_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "TCPRoute"
    metadata = {
      name      = "${local.name}-smtp-route"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [{
        name        = local.context.values.gateway_name
        namespace   = local.context.values.gateway_namespace
        sectionName = "smtp"
      }]
      rules = [{
        backendRefs = [{
          name = "${local.name}-service"
          port = local.smtp_host_port
        }]
      }]
    }
  })
}
