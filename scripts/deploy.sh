#!/usr/bin/env bash
set -euo pipefail
APP_NS="${APP_NS:-gelato}"
ARGO_NS="${ARGO_NS:-argocd}"
APP="${APP:-gelato-web}"
DOMAIN="${DOMAIN:-gelato.cybervestigio.com}"

usage(){ cat <<USAGE
Gelato Web CLI

Commands:
  install-nginx-ingress  Install ingress-nginx.
  ghcr-secret            Create/update GHCR pull secret. Requires GITHUB_USER and GHCR_TOKEN.
  apply-argocd           Apply ArgoCD app for Web.
  sync                   Sync Web app.
  status                 Show Web resources.
  logs                   Follow Web logs.
  restart                Restart Web deployment.
  ingress                Show ingress and URLs.
  local-build            Build local Docker image gelato-web:local.
  local-apply            Apply local kustomize overlay.
USAGE
}

case "${1:-help}" in
  install-nginx-ingress)
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
    kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s
    ;;
  ghcr-secret)
    : "${GITHUB_USER:?Set GITHUB_USER=94manuel}"; : "${GHCR_TOKEN:?Set GHCR_TOKEN}"
    kubectl create namespace "$APP_NS" --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n "$APP_NS" delete secret ghcr-secret --ignore-not-found
    kubectl -n "$APP_NS" create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username="$GITHUB_USER" --docker-password="$GHCR_TOKEN" --docker-email="${GITHUB_EMAIL:-devnull@example.com}"
    ;;
  apply-argocd) kubectl apply -f argocd/application.yaml ;;
  sync) argocd app sync "$APP" && argocd app wait "$APP" --health --sync --timeout 300 ;;
  status) kubectl get applications -n "$ARGO_NS" || true; kubectl get pods,deploy,svc,ingress -n "$APP_NS" || true ;;
  logs) kubectl logs -n "$APP_NS" deployment/gelato-web -f --tail=120 ;;
  restart) kubectl rollout restart deployment/gelato-web -n "$APP_NS"; kubectl rollout status deployment/gelato-web -n "$APP_NS" --timeout=300s ;;
  ingress) kubectl get ingress -n "$APP_NS"; echo "Web: https://${DOMAIN}"; echo "Swagger: https://${DOMAIN}/api/docs" ;;
  local-build) docker build -t gelato-web:local . --build-arg NEXT_PUBLIC_API_URL=/api ;;
  local-apply) kubectl apply -k k8s/overlays/local ;;
  help|--help|-h) usage ;;
  *) echo "Unknown command: $1" >&2; usage; exit 1 ;;
esac
