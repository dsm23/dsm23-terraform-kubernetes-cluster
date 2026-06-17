apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: secure-headers
  namespace: ${namespace}
spec:
  headers:
    frameDeny: true
    sslRedirect: true
    browserXssFilter: true
    contentTypeNosniff: true
    stsIncludeSubdomains: true
    stsPreload: true
    stsSeconds: 31536000
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: ip-allowlist
  namespace: ${namespace}
spec:
  ipAllowList:
    sourceRange:
      - 127.0.0.1/32
      - 10.0.0.0/8 # Typical cluster network range
      - 192.168.0.0/16 # Common local network range
