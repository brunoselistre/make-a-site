provider_name="netlify"

provider_preflight() {
    if ! command -v netlify &>/dev/null; then
        echo "ERROR: Netlify CLI is not installed. Run: npm install -g netlify-cli" >&2
        return 1
    fi
    if ! netlify status &>/dev/null; then
        echo "ERROR: Not logged in to Netlify. Run: netlify login" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local site_id="${NETLIFY_SITE_ID:-}"
    if [[ -n "$site_id" ]]; then
        netlify deploy --prod --dir="$src_dir" --site "$site_id"
    else
        netlify deploy --prod --dir="$src_dir"
    fi
}

provider_rollback() {
    local backup_dir="$1"
    local site_id="${NETLIFY_SITE_ID:-}"
    if [[ -n "$site_id" ]]; then
        netlify deploy --prod --dir="$backup_dir" --site "$site_id"
    else
        netlify deploy --prod --dir="$backup_dir"
    fi
}

provider_setup_questions() {
    echo "NETLIFY_SITE_ID="
}