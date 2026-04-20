#!/usr/bin/env bash
set -euo pipefail

echo "Executando verificações pré-deploy..."

# Verifica se src existe e não está vazio
if [ ! -d "src" ] || [ -z "$(ls -A src)" ]; then
  echo "ERRO: src/ não encontrado ou vazio." >&2
  exit 1
fi

# Verifica se as variáveis de ambiente estão definidas
ENV_FILE="${ENV_FILE:-config/.env.production}"
if [ ! -f "$ENV_FILE" ]; then
  echo "ERRO: $ENV_FILE não encontrado. Copie config/.env.example e preencha os valores." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

for var in FTP_HOST FTP_USER FTP_PASSWORD FTP_PORT REMOTE_PATH SITE_URL; do
  if [ -z "${!var:-}" ]; then
    echo "ERRO: $var não definido em $ENV_FILE" >&2
    exit 1
  fi
done

# Verifica se lftp está instalado
if ! command -v lftp &>/dev/null; then
  echo "ERRO: lftp não encontrado. Instale com:" >&2
  echo "  Mac:   brew install lftp" >&2
  echo "  Linux: sudo apt-get install -y lftp" >&2
  exit 1
fi

# Testa conectividade FTP
echo "Testando conectividade FTP com ${FTP_HOST}:${FTP_PORT}..."
if ! lftp -u "${FTP_USER},${FTP_PASSWORD}" \
     -e "set ftp:ssl-force true; set ssl:verify-certificate false; ls \"${REMOTE_PATH}\"; quit" \
     "ftp://${FTP_HOST}:${FTP_PORT}" &>/dev/null; then
  echo "ERRO: Não foi possível conectar via FTP em ${FTP_HOST}:${FTP_PORT}." >&2
  echo "      Verifique FTP_HOST, FTP_USER, FTP_PASSWORD e FTP_PORT em $ENV_FILE." >&2
  exit 1
fi

echo "Conectividade FTP OK."
echo "Verificações concluídas."
