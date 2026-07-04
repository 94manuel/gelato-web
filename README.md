# Gelato Web

Proyecto independiente del frontend Next.js para Gelato. Incluye su propio Dockerfile, CI, Kubernetes, ArgoCD, Ingress y scripts.

## Desarrollo local

```bash
npm install
npm run dev
```

Web local:

```txt
http://localhost:3000
```

## Producción

La imagen se publica como:

```txt
ghcr.io/94manuel/gelato-web:<tag>
```

El Ingress expone:

```txt
https://gelato.cybervestigio.com
https://gelato.cybervestigio.com/api/docs
```

Instalar NGINX Ingress si aún no existe:

```bash
./scripts/deploy.sh install-nginx-ingress
```

Crear secret de GHCR:

```bash
export GITHUB_USER=94manuel
export GHCR_TOKEN='TOKEN_READ_PACKAGES'
./scripts/deploy.sh ghcr-secret
```

Aplicar ArgoCD:

```bash
./scripts/deploy.sh apply-argocd
./scripts/deploy.sh sync
```

## CI

El workflow está en:

```txt
.github/workflows/gelato-web-ci.yml
```

Si este proyecto vive dentro de un monorepo con carpetas `gelato-api/` y `gelato-web/`, copia el workflow al `.github/workflows/` del root del repositorio para que GitHub Actions lo ejecute.
