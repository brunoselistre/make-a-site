#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_PROD_FILE="$ROOT_DIR/config/.env.production"

ask() {
  local prompt="$1"
  local default="${2:-}"
  local value

  if [ -n "$default" ]; then
    read -rp "$prompt [$default]: " value
    echo "${value:-$default}"
  else
    read -rp "$prompt: " value
    echo "$value"
  fi
}

warn_overwrite() {
  local file="$1"
  if [ -f "$file" ]; then
    echo ""
    echo "Atenção: $file já existe."
    read -rp "Sobrescrever? [s/N]: " confirm
    if [[ ! "$confirm" =~ ^[Ss]$ ]]; then
      echo "Pulado."
      return 1
    fi
  fi
  return 0
}

echo ""
echo "================================================"
echo "  Configuração do projeto"
echo "================================================"
echo ""

source "$SCRIPT_DIR/lib/core.sh"

DEPLOY_PROVIDER=$(ask "Provider de deploy (ftp, sftp, s3, vercel, netlify, local, rsync)" "ftp")

PROVIDER_FILE=$(cd "$SCRIPT_DIR" && core_resolve_provider "$DEPLOY_PROVIDER" 2>/dev/null || true)
if [ -z "$PROVIDER_FILE" ] || [ ! -f "$PROVIDER_FILE" ]; then
  echo "ERRO: provider '$DEPLOY_PROVIDER' não encontrado." >&2
  exit 1
fi
source "$PROVIDER_FILE"

if warn_overwrite "$ENV_PROD_FILE"; then
  echo ""
  echo "── Configuração do site ─"
  SITE_URL=$(ask "URL do site (ex: https://dominiodocliente.com.br)")

  {
    echo "# Provider"
    echo "DEPLOY_PROVIDER=${DEPLOY_PROVIDER}"
    echo ""
    echo "# Common"
    echo "SITE_URL=${SITE_URL}"
    echo ""
    provider_setup_questions
  } > "$ENV_PROD_FILE"

  chmod 600 "$ENV_PROD_FILE"
  echo "✔  config/.env.production criado."
fi

echo ""
echo "================================================"
echo "  Configuração concluída"
echo ""
echo "  Próximo passo: bash scripts/preflight.sh"
echo "================================================"
echo ""