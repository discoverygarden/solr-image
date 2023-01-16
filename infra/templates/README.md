# Helm Charts

If running locally enable traefik the traefik plugin using a node port:

```bash
values=$(cat <<EOF
service:
  type: NodePort
EOF
)
microk8s enable traefik -f <(echo "$values")
```

If running in a dev environment install the dev-secrets chart first with 
`helm install dev-secrets ./dev-secrets/` to create the required secrets.

To create the islandora stack run `helm install islandora ./islandora/`

