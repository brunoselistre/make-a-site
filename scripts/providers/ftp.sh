provider_name="ftp"

provider_preflight() {
    if ! command -v lftp &>/dev/null; then
        echo "ERROR: lftp is not installed" >&2
        return 1
    fi
    if [[ -z "$FTP_HOST" ]] || [[ -z "$FTP_USER" ]] || [[ -z "$FTP_PASSWORD" ]]; then
        echo "ERROR: FTP_HOST, FTP_USER, FTP_PASSWORD must be set" >&2
        return 1
    fi
    local port="${FTP_PORT:-21}"
    if ! lftp -c "open -p $port $FTP_HOST; user $FTP_USER $FTP_PASSWORD; ls" &>/dev/null; then
        echo "ERROR: Cannot connect to FTP server $FTP_HOST:$port" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local remote_path="${REMOTE_PATH:-/}"
    local port="${FTP_PORT:-21}"
    lftp -u "${FTP_USER},${FTP_PASSWORD}" "ftp://${FTP_HOST}:${port}" <<LFTP_CMDS
set ftp:ssl-force true
set ssl:verify-certificate false
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
    local port="${FTP_PORT:-21}"
    lftp -u "${FTP_USER},${FTP_PASSWORD}" "ftp://${FTP_HOST}:${port}" <<LFTP_CMDS
set ftp:ssl-force true
set ssl:verify-certificate false
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
    echo "FTP_HOST="
    echo "FTP_USER="
    echo "FTP_PASSWORD="
    echo "FTP_PORT=21"
    echo "REMOTE_PATH=/"
}