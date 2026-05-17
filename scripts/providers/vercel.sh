provider_name="vercel"

provider_preflight() {
    if ! command -v vercel &>/dev/null; then
        echo "ERROR: Vercel CLI is not installed. Run: npm install -g vercel" >&2
        return 1
    fi
    if ! vercel whoami &>/dev/null; then
        echo "ERROR: Not logged in to Vercel. Run: vercel login" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    cd "$src_dir"
    vercel --prod
}

provider_rollback() {
    local backup_dir="$1"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    echo "Rollback for Vercel requires manual intervention via dashboard"
    vercel list | head -5
}

provider_setup_questions() {
    echo "VERCEL_PROJECT="
}