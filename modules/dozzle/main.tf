locals {
  name = "dozzle"

  container_port = 8080
  host_port      = 8080

  rbac_name = "pod-viewer"
  role_name = "pod-viewer-role"
}

resource "docker_image" "dozzle_image" {
  name          = data.docker_registry_image.dozzle_image.name
  pull_triggers = [data.docker_registry_image.dozzle_image.sha256_digest]

  keep_locally = true
}

resource "kubernetes_service_account_v1" "rbac" {
  metadata {
    name      = local.rbac_name
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_v1" "cluster_role" {
  metadata {
    name = local.role_name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "pod_viewer_binding" {
  metadata {
    name = "pod-viewer-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.role_name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.rbac_name
    namespace = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim_v1" "dozzle_data" {
  metadata {
    name      = "dozzle-data"
    namespace = var.namespace
  }

  # k3d only
  # wait_until_bound = false

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# ReadWriteOnce + Recreate strategy means cloud config / notification rules
# briefly become unavailable during pod rollouts (the new pod can't mount until
# the old one releases). For zero-downtime config persistence, use a
# ReadWriteMany storage class (NFS, CephFS, etc.) and switch the strategy
# below to RollingUpdate.
resource "kubernetes_deployment_v1" "dozzle_deployment" {
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

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app = local.name
        }
      }

      spec {
        service_account_name = local.rbac_name

        container {
          name  = "webapp"
          image = docker_image.dozzle_image.name

          port {
            container_port = local.container_port
            protocol       = "TCP"
            name           = "http"
          }

          env {
            name  = "DOZZLE_MODE"
            value = "k8s"
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          startup_probe {
            http_get {
              path = "/healthcheck"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/healthcheck"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/healthcheck"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = "dozzle-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "dozzle_service" {
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
      port        = local.host_port
      target_port = local.container_port
      protocol    = "TCP"
    }
  }
}


resource "kubectl_manifest" "dozzle_route" {
  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"
    metadata = {
      name      = "${local.name}-route"
      namespace = var.namespace
    }
    spec = {
      parentRefs = [{
        name        = var.gateway_name
        namespace   = "traefik"
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
