data "context_config" "config" {}

data "docker_registry_image" "docuseal_image" {
  name = "docuseal/docuseal:${var.release_version}"
}
