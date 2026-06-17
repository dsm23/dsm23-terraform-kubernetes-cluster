# Configure Network Ports and EntryPoints
# EntryPoints are the network listeners for incoming traffic.
ports:
  # Defines the HTTP entry point named 'web'
  web:
    port: 80
    nodePort: 30000
    # address: "[::]:80"
    # Instructs this entry point to redirect all traffic to the 'websecure' entry point
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
          permanent: true

  websecure:
    port: 443
    nodePort: 30001
    # http3: {}
    protocol: TCP
    # address: "[::]:443"

  # websecure-udp:
  #   port: 443
  #   nodePort: 30001
  #   protocol: UDP

  tls-passthrough:
    port: 3443
    nodePort: 30002

  tls:
    port: 8443
    nodePort: 30003

  smtp:
    port: 587
    nodePort: 30004

# Enables the dashboard in Secure Mode
api:
  dashboard: true
  insecure: false

ingressRoute:
  dashboard:
    enabled: true
    matchRule: Host(`dashboard.docker.localhost`)
    entryPoints:
      - websecure
    middlewares:
      - name: dashboard-auth

# Creates a BasiAuth Middleware and Secret for the Dashboard Security
extraObjects:
  - apiVersion: v1
    kind: Secret
    metadata:
      name: dashboard-auth-secret
      namespace: ${namespace}
    type: kubernetes.io/basic-auth
    stringData:
      username: admin
      password: "password" # Replace with an Actual Password
  - apiVersion: traefik.io/v1alpha1
    kind: Middleware
    metadata:
      name: dashboard-auth
    spec:
      basicAuth:
        secret: dashboard-auth-secret

# We will route with Gateway API instead.
ingressClass:
  enabled: false

# Enable Gateway API Provider & Disables the KubernetesIngress provider
# Providers tell Traefik where to find routing configuration.
providers:
  kubernetesIngress:
    enabled: false
  kubernetesGateway:
    enabled: true
    experimentalChannel: true

## Gateway Listeners
gateway:
  enabled: false

gatewayClass:
  enabled: false

# Enable Observability
logs:
  general:
    level: INFO
  # This enables access logs, outputting them to Traefik's standard output by default. The [Access Logs Documentation](https://doc.traefik.io/traefik/observability/access-logs/) covers formatting, filtering, and output options.
  access:
    enabled: true

# Enables Prometheus for Metrics
metrics:
  prometheus:
    enabled: true
    # The entry point metrics will be available on (usually internal/admin)
    entryPoint: metrics
    # Add standard Prometheus metrics
    addRoutersLabels: true
    addServicesLabels: true
    additionalArguments:
      - "--tracing.otel=true"
      - "--tracing.otel.grpcendpoint=otel-collector.observability:4317" # Adjust endpoint as needed
      - "--tracing.otel.httpendpoint=otel-collector.observability:4318" # Adjust endpoint as needed
