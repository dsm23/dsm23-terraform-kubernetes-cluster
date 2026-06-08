variable "k3s_version" {
  type        = string
  default     = "v1.36.0-k3s1"
  description = "The version of k3s to deploy."
}

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
