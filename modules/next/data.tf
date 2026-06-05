data "docker_registry_image" "next_template_image" {
  name = "ghcr.io/dsm23/dsm23-next-template:${var.release_version}"
}
