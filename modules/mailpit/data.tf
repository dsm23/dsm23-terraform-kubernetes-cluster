data "docker_registry_image" "mailpit_image" {
  name = "axllent/mailpit:${var.release_version}"
}
