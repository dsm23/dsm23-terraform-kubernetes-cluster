data "docker_registry_image" "solid_start_image" {
  name = "ghcr.io/dsm23/dsm23-solid-start-template:${var.release_version}"
}
