apiVersion: http.keda.sh/v1beta1
kind: InterceptorRoute
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  target:
    service: ${serviceName}
    port: ${hostPort}
  rules:
    - hosts: ${jsonencode(hostnames)}
  scalingMetric:
    requestRate:
      targetValue: 10
      window: 1m
      granularity: 1s
