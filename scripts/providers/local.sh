provider_name="local"

provider_preflight() {
    if [[ -z "$LOCAL_DEST_DIR" ]]; then
        echo "ERROR: LOCAL_DEST_DIR must be set" >&2
        return 1
    fi
    if [[ "$LOCAL_DEST_DIR" == "/" ]]; then
        echo "ERROR: LOCAL_DEST_DIR cannot be root" >&2
        return 1
    fi
    if [[ ! -d "$LOCAL_DEST_DIR" ]]; then
        if ! mkdir -p "$LOCAL_DEST_DIR" 2>/dev/null; then
            echo "ERROR: Cannot create LOCAL_DEST_DIR: $LOCAL_DEST_DIR" >&2
            return 1
        fi
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    rm -rf "$LOCAL_DEST_DIR"/*
    cp -r "$src_dir"/* "$LOCAL_DEST_DIR/"
}

provider_rollback() {
    local backup_dir="$1"
    rm -rf "$LOCAL_DEST_DIR"/*
    cp -r "$backup_dir"/* "$LOCAL_DEST_DIR/"
}

provider_setup_questions() {
    echo "LOCAL_DEST_DIR="
}