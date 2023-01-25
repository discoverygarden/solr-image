# Helm Charts

If running locally setup traefik to use a node port:

```bash
microk8s helm repo add traefik https://helm.traefik.io/traefik
microk8s helm -n traefik upgrade --install --create-namespace traefik traefik/traefik  --set service.type=NodePort
```

If running in a dev environment install the dev-secrets chart first with 
`helm install dev-secrets ./dev-secrets/` to create the required secrets.

To create the islandora stack run `helm install islandora ./islandora/ --timeout 30m --set ingress.host=<YOUR_HOSTNAME>`

