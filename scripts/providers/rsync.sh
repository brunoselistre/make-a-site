provider_name="rsync"

provider_preflight() {
    if ! command -v rsync &>/dev/null; then
        echo "ERROR: rsync is not installed" >&2
        return 1
    fi
    if [[ -z "$RSYNC_HOST" ]] || [[ -z "$RSYNC_USER" ]] || [[ -z "$REMOTE_PATH" ]]; then
        echo "ERROR: RSYNC_HOST, RSYNC_USER, REMOTE_PATH must be set" >&2
        return 1
    fi
    local port="${RSYNC_PORT:-22}"
    if ! ssh -p "$port" "$RSYNC_USER@$RSYNC_HOST" "ls /" &>/dev/null; then
        echo "ERROR: Cannot connect to RSYNC_HOST $RSYNC_HOST:$port" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local port="${RSYNC_PORT:-22}"
    local ssh_opts="ssh -p $port"
    if [[ -n "$RSYNC_KEY" ]]; then
        ssh_opts="ssh -i $RSYNC_KEY -p $port"
    fi
    rsync -avz --delete -e "$ssh_opts" "$src_dir/" "$RSYNC_USER@$RSYNC_HOST:$REMOTE_PATH"
}

provider_rollback() {
    local backup_dir="$1"
    local port="${RSYNC_PORT:-22}"
    local ssh_opts="ssh -p $port"
    if [[ -n "$RSYNC_KEY" ]]; then
        ssh_opts="ssh -i $RSYNC_KEY -p $port"
    fi
    rsync -avz --delete -e "$ssh_opts" "$backup_dir/" "$RSYNC_USER@$RSYNC_HOST:$REMOTE_PATH"
}

provider_setup_questions() {
    echo "RSYNC_HOST="
    echo "RSYNC_USER="
    echo "RSYNC_PORT=22"
    echo "REMOTE_PATH="
    echo "RSYNC_KEY="
}