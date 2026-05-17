provider_name="sftp"

provider_preflight() {
    if ! command -v lftp &>/dev/null; then
        echo "ERROR: lftp is not installed" >&2
        return 1
    fi
    if [[ -z "$SFTP_HOST" ]] || [[ -z "$SFTP_USER" ]]; then
        echo "ERROR: SFTP_HOST, SFTP_USER must be set" >&2
        return 1
    fi
    local port="${SFTP_PORT:-22}"
    if ! lftp -c "open -p $port -u $SFTP_USER,$SFTP_PASSWORD sftp://$SFTP_HOST; ls" &>/dev/null; then
        echo "ERROR: Cannot connect to SFTP server $SFTP_HOST:$port" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local remote_path="${REMOTE_PATH:-/}"
    local port="${SFTP_PORT:-22}"
    lftp -u "${SFTP_USER},${SFTP_PASSWORD}" "sftp://${SFTP_HOST}:${port}" <<LFTP_CMDS
set sftp:auto-confirm yes
set net:max-retries 3
set net:reconnect-interval-base 5
mirror --reverse --delete --verbose \
  --exclude-glob .git \
  --exclude-glob .DS_Store \
  "$src_dir" "$remote_path"
quit
LFTP_CMDS
}

provider_rollback() {
    local backup_dir="$1"
    local remote_path="${REMOTE_PATH:-/}"
    local port="${SFTP_PORT:-22}"
    lftp -u "${SFTP_USER},${SFTP_PASSWORD}" "sftp://${SFTP_HOST}:${port}" <<LFTP_CMDS
set sftp:auto-confirm yes
set net:max-retries 3
set net:reconnect-interval-base 5
mirror --reverse --delete --verbose \
  --exclude-glob .git \
  --exclude-glob .DS_Store \
  "$backup_dir" "$remote_path"
quit
LFTP_CMDS
}

provider_setup_questions() {
    echo "SFTP_HOST="
    echo "SFTP_USER="
    echo "SFTP_PASSWORD="
    echo "SFTP_PORT=22"
    echo "REMOTE_PATH=/"
}