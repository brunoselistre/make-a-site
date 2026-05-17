#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

source scripts/lib/core.sh

ENVIRONMENT="${1:-production}"
ENV_FILE="config/.env.${ENVIRONMENT}"

core_load_env "$ENV_FILE"

if [ ! -d "src" ] || [ -z "$(ls -A src)" ]; then
  echo "ERRO: src/ não encontrado ou vazio." >&2
  exit 1
fi

PROVIDER_FILE=$(core_resolve_provider "${DEPLOY_PROVIDER:-}")
source "$PROVIDER_FILE"

provider_preflight