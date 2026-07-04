param([string]$Command = "help")
$AppNs = if ($env:APP_NS) { $env:APP_NS } else { "gelato" }
$App = if ($env:APP) { $env:APP } else { "gelato-web" }
$Domain = if ($env:DOMAIN) { $env:DOMAIN } else { "gelato.cybervestigio.com" }
switch ($Command) {
  "install-nginx-ingress" { kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml; kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=300s }
  "ghcr-secret" {
    if (-not $env:GITHUB_USER -or -not $env:GHCR_TOKEN) { throw "Set GITHUB_USER and GHCR_TOKEN" }
    kubectl create namespace $AppNs --dry-run=client -o yaml | kubectl apply -f -
    kubectl -n $AppNs delete secret ghcr-secret --ignore-not-found
    kubectl -n $AppNs create secret docker-registry ghcr-secret --docker-server=ghcr.io --docker-username=$env:GITHUB_USER --docker-password=$env:GHCR_TOKEN --docker-email=devnull@example.com
  }
  "apply-argocd" { kubectl apply -f argocd/application.yaml }
  "sync" { argocd app sync $App; argocd app wait $App --health --sync --timeout 300 }
  "status" { kubectl get pods,deploy,svc,ingress -n $AppNs }
  "logs" { kubectl logs -n $AppNs deployment/gelato-web -f --tail=120 }
  "restart" { kubectl rollout restart deployment/gelato-web -n $AppNs; kubectl rollout status deployment/gelato-web -n $AppNs --timeout=300s }
  "ingress" { kubectl get ingress -n $AppNs; Write-Host "Web: https://$Domain"; Write-Host "Swagger: https://$Domain/api/docs" }
  "local-build" { docker build -t gelato-web:local . --build-arg NEXT_PUBLIC_API_URL=/api }
  "local-apply" { kubectl apply -k k8s/overlays/local }
  default { Write-Host "Commands: install-nginx-ingress, ghcr-secret, apply-argocd, sync, status, logs, restart, ingress, local-build, local-apply" }
}
