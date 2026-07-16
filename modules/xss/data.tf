data "context_config" "config" {}

data "docker_registry_image" "xss_image" {
  name = "ghcr.io/dsm23/totally-not-xss-vulnerable:${var.release_version}"
}
