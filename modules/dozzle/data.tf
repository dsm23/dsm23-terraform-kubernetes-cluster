data "docker_registry_image" "dozzle_image" {
  name = "amir20/dozzle:${var.release_version}"
}
