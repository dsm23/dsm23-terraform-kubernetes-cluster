output "namespace" {
  description = "The name of the namespace deployed for Traefik / Reverse Proxy"
  value       = helm_release.traefik.namespace
}
