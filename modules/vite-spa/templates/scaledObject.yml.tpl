apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  scaleTargetRef:
    name: ${deploymentName}
  minReplicaCount: 0 # Allows scaling to zero!
  cooldownPeriod: 30
  triggers:
    - type: external-push
      metadata:
        # Points back to the KEDA HTTP add-on scaler component
        scalerAddress: keda-add-ons-http-external-scaler.keda:9090
        interceptorRoute: ${interceptorRoute}
