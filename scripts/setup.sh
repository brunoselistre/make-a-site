#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_PROD_FILE="$ROOT_DIR/config/.env.production"

# ---------------------------------------------------------------------------
# Utilitários
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Cabeçalho
# ---------------------------------------------------------------------------
echo ""
echo "================================================"
echo "  Configuração do projeto"
echo "================================================"
echo ""

# ---------------------------------------------------------------------------
# config/.env.production  (credenciais FTP — somente shell)
# ---------------------------------------------------------------------------
if warn_overwrite "$ENV_PROD_FILE"; then
  echo "── Credenciais FTP do servidor (config/.env.production) ─"
  echo "   Usadas pelos scripts de deploy. Nunca commitadas."
  echo "   Encontre estes valores em: hPanel > Arquivos > Contas FTP"
  echo ""

  FTP_HOST=$(ask "Hostname FTP (ex: files.hostinger.com)")
  FTP_USER=$(ask "Usuário FTP (ex: u123456789)")
  FTP_PASSWORD=$(ask "Senha FTP")
  FTP_PORT=$(ask "Porta FTP" "21")
  REMOTE_PATH=$(ask "Caminho remoto (ex: /home/u123456789/public_html)")
  SITE_URL=$(ask "URL do site (ex: https://dominiodocliente.com.br)")

  {
    echo "# Credenciais FTP — lidas pelos scripts de deploy"
    echo "FTP_HOST=${FTP_HOST}"
    echo "FTP_USER=${FTP_USER}"
    echo "FTP_PASSWORD=${FTP_PASSWORD}"
    echo "FTP_PORT=${FTP_PORT}"
    echo "REMOTE_PATH=${REMOTE_PATH}"
    echo "SITE_URL=${SITE_URL}"
  } > "$ENV_PROD_FILE"

  chmod 600 "$ENV_PROD_FILE"
  echo "✔  config/.env.production criado."
fi

# ---------------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------------
echo ""
echo "================================================"
echo "  Configuração concluída"
echo ""
echo "  Próximo passo: bash scripts/preflight.sh"
echo "================================================"
echo ""
