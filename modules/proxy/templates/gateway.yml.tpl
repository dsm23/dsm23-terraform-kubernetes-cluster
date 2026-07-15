apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: ${gatewayName}
  namespace: ${namespace}
spec:
  gatewayClassName: ${gatewayClassName}
  listeners:
    - name: web
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
      http:
        redirections:
          entryPoint:
            to: websecure
            scheme: https
            permanent: true

    - name: websecure
      protocol: HTTPS
      port: 443
      tls:
        mode: Terminate
        certificateRefs:
          - kind: Secret
            name: ${secretName}
            namespace: ${certificateNamespace}
      allowedRoutes:
        namespaces:
          from: Selector
          selector:
            matchLabels:
              gateway-access: "true"

    - name: smtp
      protocol: TCP
      port: 587
      allowedRoutes:
        kinds:
          - kind: TCPRoute
        namespaces:
          from: Same

    - name: tls-passthrough
      protocol: TLS
      port: 3443
      tls:
        mode: Passthrough
      allowedRoutes:
        kinds:
          - kind: TLSRoute
        namespaces:
          from: Selector
          selector:
            matchLabels:
              gateway-access: "true"

    - name: tls
      protocol: TLS
      port: 8443
      tls:
        mode: Terminate
        certificateRefs:
          - kind: Secret
            name: secret-tls
            namespace: ${certificateNamespace}
      allowedRoutes:
        kinds:
          - kind: TLSRoute
        namespaces:
          from: Selector
          selector:
            matchLabels:
              gateway-access: "true"
