#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

source scripts/lib/core.sh

ENVIRONMENT="${1:-production}"
ENV_FILE="config/.env.${ENVIRONMENT}"

core_load_env "$ENV_FILE"
PROVIDER_FILE=$(core_resolve_provider "${DEPLOY_PROVIDER:-}")
source "$PROVIDER_FILE"

bash scripts/preflight.sh "$ENVIRONMENT"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOCAL_BACKUP_DIR=$(core_backup_src)

provider_deploy

HTTP_STATUS=$(core_smoke_test "${SITE_URL:-}" || true)
core_print_summary "$ENVIRONMENT" "$TIMESTAMP" "$LOCAL_BACKUP_DIR" "${SITE_URL:-}" "${HTTP_STATUS:-}"