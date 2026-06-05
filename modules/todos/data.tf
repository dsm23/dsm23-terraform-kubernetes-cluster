data "docker_registry_image" "todos_image" {
  name = "ghcr.io/dsm23/todomvc-redux-example:${var.release_version}"
}
