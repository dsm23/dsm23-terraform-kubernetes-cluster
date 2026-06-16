httpRoute:
  enabled: true
  hostnames: ${jsonencode(hostnames)}
  parentRefs:
    - name: ${gatewayName}
      sectionName: websecure
