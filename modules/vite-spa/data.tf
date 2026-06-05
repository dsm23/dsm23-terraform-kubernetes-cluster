data "docker_registry_image" "vite_spa_template_image" {
  name = "ghcr.io/dsm23/dsm23-vite-spa-template:${var.release_version}"
}
