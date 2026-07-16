expose:
  tls:
    enabled: false
  type: route
  route:
    hosts: ${jsonencode(hostnames)}
    parentRefs:
      - name: ${name}
        namespace: ${namespace}
        sectionName: websecure

# harborAdminPassword: password
