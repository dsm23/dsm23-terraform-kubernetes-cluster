data "context_config" "config" {}

data "docker_registry_image" "browserless_image" {
  name = "ghcr.io/browserless/chromium:${var.release_version}"
}
