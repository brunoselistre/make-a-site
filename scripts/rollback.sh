#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

source scripts/lib/core.sh

ENVIRONMENT="${1:-production}"
DATE_FILTER="${2:-}"
ENV_FILE="config/.env.${ENVIRONMENT}"

core_load_env "$ENV_FILE"
PROVIDER_FILE=$(core_resolve_provider "${DEPLOY_PROVIDER:-}")
source "$PROVIDER_FILE"

TARGET=$(core_select_backup "$DATE_FILTER")
BACKUP_PATH="backups/${TARGET}"

provider_rollback "$BACKUP_PATH"

HTTP_STATUS=$(core_smoke_test "${SITE_URL:-}" || true)
core_print_rollback_summary "$ENVIRONMENT" "$TARGET" "${SITE_URL:-}" "${HTTP_STATUS:-}"