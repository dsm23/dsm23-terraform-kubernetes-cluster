httpRoute:
  enabled: true
  hostnames: ${jsonencode(hostnames)}
  parentRefs:
    - name: ${gatewayName}
      namespace: ${gatewayNamespace}
      sectionName: websecure
