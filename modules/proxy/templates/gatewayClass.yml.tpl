apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: ${gatewayClassName}
  namespace: ${namespace}
spec:
  controllerName: traefik.io/gateway-controller
