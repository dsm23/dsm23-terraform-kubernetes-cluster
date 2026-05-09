variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "docker_host" {
  type        = string
  default     = "unix:///Users/davidmurdoch/.docker/run/docker.sock"
  description = "docker socket file location"
}
