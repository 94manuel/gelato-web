# ArgoCD - gelato-web

Aplica esta aplicación desde la raíz del repositorio que contiene `gelato-api/` y `gelato-web/`:

```bash
kubectl apply -f gelato-web/argocd/application.yaml
```

La ruta GitOps configurada es:

```txt
gelato-web/k8s/overlays/prod
```
