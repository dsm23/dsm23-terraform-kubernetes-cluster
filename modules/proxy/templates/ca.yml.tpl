apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${name}
  namespace: ${namespace}
spec:
  isCA: true
  commonName: ${commonName}
  secretName: ${secretName}
  privateKey:
    algorithm: ECDSA
    rotationPolicy: Always
  issuerRef:
    name: ${clusterIssuerName}
    kind: ClusterIssuer
    group: cert-manager.io
