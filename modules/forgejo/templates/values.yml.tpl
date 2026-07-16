httpRoute:
  enabled: true
  hostnames: ${jsonencode(hostnames)}
  parentRefs:
    - name: ${name}
      namespace: ${namespace}
      sectionName: websecure
