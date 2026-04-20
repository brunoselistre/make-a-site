#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# ---------------------------------------------------------------------------
# 0. Argumentos
# ---------------------------------------------------------------------------
ENVIRONMENT="${1:-production}"
ENV_FILE="config/.env.${ENVIRONMENT}"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERRO: arquivo de ambiente não encontrado: $ENV_FILE" >&2
  echo "      Copie config/.env.example para $ENV_FILE e preencha os valores." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

# ---------------------------------------------------------------------------
# 1. Preflight
# ---------------------------------------------------------------------------
bash scripts/preflight.sh

# ---------------------------------------------------------------------------
# 2. Backup local de src/
# ---------------------------------------------------------------------------
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOCAL_BACKUP_DIR="backups/src-${TIMESTAMP}"

echo "==> Criando backup local em ${LOCAL_BACKUP_DIR}..."
mkdir -p backups
cp -r src/ "${LOCAL_BACKUP_DIR}"

# ---------------------------------------------------------------------------
# 3. Upload via lftp mirror
# ---------------------------------------------------------------------------
echo "==> Enviando src/ para ${FTP_HOST}:${REMOTE_PATH}..."
lftp -u "${FTP_USER},${FTP_PASSWORD}" "ftp://${FTP_HOST}:${FTP_PORT}" <<LFTP_CMDS
set ftp:ssl-force true
set ssl:verify-certificate false
set net:max-retries 3
set net:reconnect-interval-base 5
mirror --reverse --delete --verbose \
  --exclude-glob .git \
  --exclude-glob .DS_Store \
  ./src/ ${REMOTE_PATH}/
quit
LFTP_CMDS

# ---------------------------------------------------------------------------
# 4. Teste de fumaça
# ---------------------------------------------------------------------------
echo "==> Executando teste de fumaça em ${SITE_URL}..."
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" --max-time 15 -L "${SITE_URL}")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "ERRO: Teste de fumaça falhou — HTTP ${HTTP_STATUS}." >&2
  echo "Para reverter, execute:" >&2
  echo "  bash scripts/rollback.sh ${ENVIRONMENT} ${TIMESTAMP}" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 5. Resumo
# ---------------------------------------------------------------------------
echo ""
echo "================================================"
echo "  Deploy concluído"
echo "  Ambiente    : ${ENVIRONMENT}"
echo "  Timestamp   : ${TIMESTAMP}"
echo "  Backup local: ${LOCAL_BACKUP_DIR}"
echo "  Site        : ${SITE_URL} (HTTP ${HTTP_STATUS})"
echo "================================================"
