data "docker_registry_image" "svelte_kit_image" {
  name = "ghcr.io/dsm23/dsm23-svelte-kit-template:${var.release_version}"
}
