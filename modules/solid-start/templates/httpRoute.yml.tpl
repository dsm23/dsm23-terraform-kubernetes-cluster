apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  parentRefs:
    - name: ${gatewayName}
      namespace: ${gatewayNamespace}
      sectionName: websecure
  hostnames: ${jsonencode(hostnames)}
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
          filters:
            - type: ExtensionRef
              extensionRef:
                group: traefik.io
                kind: Middleware
                name: secure-headers
            - type: ExtensionRef
              extensionRef:
                group: traefik.io
                kind: Middleware
                name: ip-allowlist
      backendRefs:
        - name: keda-add-ons-http-interceptor-proxy
          namespace: keda
          port: 8080
