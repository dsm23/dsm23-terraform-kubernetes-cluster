apiVersion: policies.kyverno.io/v1
kind: NamespacedValidatingPolicy
metadata:
  name: check-labels
  namespace: ${namespace}
spec:
  validationActions:
    - Deny
  matchConstraints:
    resourceRules:
      - apiGroups: ['']
        apiVersions: [v1]
        operations: [CREATE, UPDATE]
        resources: [pods]
  validations:
    - message: label 'environment' is required
      expression: "'environment' in object.metadata.?labels.orValue([])"
