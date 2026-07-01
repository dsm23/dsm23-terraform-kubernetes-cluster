locals {
  name = "xss"

  container_port = 80
  host_port      = 80

  deployment_name        = local.name
  service_name           = local.name
  interceptor_route_name = "${local.name}-interceptor-route"
}

resource "docker_image" "xss_image" {
  name          = data.docker_registry_image.xss_image.name
  pull_triggers = [data.docker_registry_image.xss_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_deployment_v1" "xss" {
  metadata {
    name      = local.deployment_name
    namespace = var.namespace
  }

  spec {
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
          image = docker_image.xss_image.name

          port {
            container_port = local.container_port
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

resource "kubernetes_service_v1" "xss_service" {
  metadata {
    name      = local.service_name
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

resource "kubectl_manifest" "xss_route" {
  yaml_body = templatefile("${path.module}/templates/httpRoute.yml.tpl", {
    name        = "${local.name}-route"
    namespace   = var.namespace
    gatewayName = var.gateway_name
    hostnames   = var.hostnames
  })
}

resource "kubectl_manifest" "xss_interceptor_route" {
  yaml_body = templatefile("${path.module}/templates/interceptorRoute.yml.tpl", {
    name        = local.interceptor_route_name
    namespace   = var.namespace
    hostnames   = var.hostnames
    serviceName = local.service_name
    hostPort    = local.host_port
  })
}

resource "kubectl_manifest" "xss_scaled_object" {
  yaml_body = templatefile("${path.module}/templates/scaledObject.yml.tpl", {
    name             = "${local.name}-scaled-object"
    namespace        = var.namespace
    deploymentName   = local.name
    interceptorRoute = local.interceptor_route_name
  })
}
