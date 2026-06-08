data "docker_registry_image" "vaultwarden_image" {
  name = "vaultwarden/server:${var.release_version}"
}
