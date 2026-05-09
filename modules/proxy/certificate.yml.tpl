apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: whoami
  namespace: ${namespace}
spec:
  secretName: ${secretName}        # Name of secret where the generated certificate will be stored.
  dnsNames:
    - "localhost" # Replace a real domain
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
