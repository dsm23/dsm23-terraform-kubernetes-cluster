expose:
  tls:
    enabled: false
  type: route
  route:
    hosts: ${jsonencode(hostnames)}
    parentRefs:
      - name: ${gatewayName}
        namespace: ${gatewayNamespace}
        sectionName: websecure

# harborAdminPassword: password
