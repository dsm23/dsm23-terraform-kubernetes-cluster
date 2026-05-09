resource "docker_image" "k3s" {
  name         = "rancher/k3s:v1.36.0-k3s1"
  keep_locally = true
}

resource "k3d_cluster" "k3d" {
  name = "local-cluster"

  k3d_config = templatefile("${path.module}/localClusterConfig.yml.tpl", { cluster_image = docker_image.k3s.name })
}

resource "kubernetes_namespace_v1" "traefik_namespace" {
  metadata {
    name = "traefik"
  }
}

module "reverse_proxy" {
  source = "./modules/proxy"

  proxy_namespace = kubernetes_namespace_v1.traefik_namespace.metadata[0].name
}

module "vite-spa" {
  depends_on = [module.reverse_proxy]

  source = "./modules/vite"

  release_namespace = kubernetes_namespace_v1.traefik_namespace.metadata[0].name
}


module "next-template" {
  depends_on = [module.reverse_proxy]

  source = "./modules/next"

  release_namespace = kubernetes_namespace_v1.traefik_namespace.metadata[0].name
}
