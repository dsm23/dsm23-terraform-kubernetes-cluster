provider "docker" {
  host = var.docker_host
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "kubernetes" {
  host                   = resource.k3d_cluster.k3d.host
  client_certificate     = base64decode(resource.k3d_cluster.k3d.client_certificate)
  client_key             = base64decode(resource.k3d_cluster.k3d.client_key)
  cluster_ca_certificate = base64decode(resource.k3d_cluster.k3d.cluster_ca_certificate)

}

provider "helm" {
  kubernetes = {
    host                   = resource.k3d_cluster.k3d.host
    client_certificate     = base64decode(resource.k3d_cluster.k3d.client_certificate)
    client_key             = base64decode(resource.k3d_cluster.k3d.client_key)
    cluster_ca_certificate = base64decode(resource.k3d_cluster.k3d.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = resource.k3d_cluster.k3d.host
  client_certificate     = base64decode(resource.k3d_cluster.k3d.client_certificate)
  client_key             = base64decode(resource.k3d_cluster.k3d.client_key)
  cluster_ca_certificate = base64decode(resource.k3d_cluster.k3d.cluster_ca_certificate)
}
