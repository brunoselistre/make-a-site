#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# ---------------------------------------------------------------------------
# 0. Argumentos
# ---------------------------------------------------------------------------
ENVIRONMENT="${1:-production}"
DATE_FILTER="${2:-}"       # opcional: timestamp parcial, ex: 20250415 ou 20250415-143022

ENV_FILE="config/.env.${ENVIRONMENT}"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERRO: arquivo de ambiente não encontrado: $ENV_FILE" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

BACKUPS_ROOT="${ROOT_DIR}/backups"

# ---------------------------------------------------------------------------
# 1. Listar backups locais disponíveis
# ---------------------------------------------------------------------------
if [ ! -d "$BACKUPS_ROOT" ] || [ -z "$(ls -A "$BACKUPS_ROOT" 2>/dev/null)" ]; then
  echo "ERRO: Nenhum backup local encontrado em backups/." >&2
  echo "      Backups são criados automaticamente a cada deploy bem-sucedido." >&2
  exit 1
fi

# Lista em ordem decrescente (mais recente primeiro)
BACKUP_LIST=$(ls -1t "$BACKUPS_ROOT")

# ---------------------------------------------------------------------------
# 2. Selecionar backup
# ---------------------------------------------------------------------------
if [ -n "$DATE_FILTER" ]; then
  TARGET=$(echo "$BACKUP_LIST" | grep "$DATE_FILTER" | head -n 1)
  if [ -z "$TARGET" ]; then
    echo "ERRO: Nenhum backup encontrado com '${DATE_FILTER}'." >&2
    echo "Backups disponíveis:" >&2
    echo "$BACKUP_LIST" >&2
    exit 1
  fi
  echo "==> Backup selecionado: ${TARGET}"
else
  echo "Backups disponíveis (mais recente primeiro):"
  echo "$BACKUP_LIST"
  echo ""
  TARGET=$(echo "$BACKUP_LIST" | head -n 1)
  echo "==> Padrão: backup mais recente: ${TARGET}"
  read -r -p "Confirmar? [s/N] " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo "Operação cancelada."
    exit 0
  fi
fi

BACKUP_PATH="${BACKUPS_ROOT}/${TARGET}"

# ---------------------------------------------------------------------------
# 3. Verificar lftp
# ---------------------------------------------------------------------------
if ! command -v lftp &>/dev/null; then
  echo "ERRO: lftp não encontrado. Instale com:" >&2
  echo "  Mac:   brew install lftp" >&2
  echo "  Linux: sudo apt-get install -y lftp" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 4. Re-upload do backup via lftp mirror
# ---------------------------------------------------------------------------
echo "==> Restaurando ${TARGET} -> ${FTP_HOST}:${REMOTE_PATH}..."
lftp -u "${FTP_USER},${FTP_PASSWORD}" "ftp://${FTP_HOST}:${FTP_PORT}" <<LFTP_CMDS
set ftp:ssl-force true
set ssl:verify-certificate false
set net:max-retries 3
set net:reconnect-interval-base 5
mirror --reverse --delete --verbose \
  --exclude-glob .git \
  --exclude-glob .DS_Store \
  "${BACKUP_PATH}/" ${REMOTE_PATH}/
quit
LFTP_CMDS

# ---------------------------------------------------------------------------
# 5. Teste de fumaça
# ---------------------------------------------------------------------------
echo "==> Executando teste de fumaça em ${SITE_URL}..."
HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}" --max-time 15 -L "${SITE_URL}")

if [ "$HTTP_STATUS" != "200" ]; then
  echo "AVISO: Teste de fumaça retornou HTTP ${HTTP_STATUS} após reversão." >&2
  echo "       O site pode precisar de investigação adicional." >&2
else
  echo "Teste de fumaça aprovado (HTTP ${HTTP_STATUS})."
fi

# ---------------------------------------------------------------------------
# 6. Confirmação
# ---------------------------------------------------------------------------
echo ""
echo "================================================"
echo "  Reversão concluída"
echo "  Ambiente    : ${ENVIRONMENT}"
echo "  Restaurado  : ${TARGET}"
echo "  Site        : ${SITE_URL} (HTTP ${HTTP_STATUS})"
echo "================================================"
