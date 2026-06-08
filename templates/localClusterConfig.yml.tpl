apiVersion: k3d.io/v1alpha5
kind: Simple
metadata:
  name: "k3d-cluster"
servers: 1
agents: 2
image: ${cluster_image}
ports:
  - port: 80:80
    nodeFilters:
      - loadbalancer
  - port: 443:443
    nodeFilters:
      - loadbalancer
options:
  k3d:
    wait: true
    disableLoadbalancer: false
  k3s:
    extraArgs:
      - arg: "--disable=traefik"
        nodeFilters:
          - server:*
