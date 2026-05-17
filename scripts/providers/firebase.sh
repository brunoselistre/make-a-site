provider_name="firebase"

provider_preflight() {
    if ! command -v firebase &>/dev/null; then
        echo "ERROR: Firebase CLI is not installed. Run: npm install -g firebase-tools" >&2
        return 1
    fi
    if [[ -z "${FIREBASE_TOKEN:-}" ]]; then
        if ! firebase projects:list &>/dev/null; then
            echo "ERROR: Not logged in to Firebase. Run: firebase login, or set FIREBASE_TOKEN for CI." >&2
            return 1
        fi
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local project_id="${FIREBASE_PROJECT_ID:-}"
    local token="${FIREBASE_TOKEN:-}"
    local cmd="firebase deploy --only hosting"

    if [[ -n "$project_id" ]]; then
        cmd="$cmd --project $project_id"
    fi
    if [[ -n "$token" ]]; then
        cmd="$cmd --token $token"
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    cat > "$tmp_dir/firebase.json" <<EOF
{
  "hosting": {
    "public": "$src_dir",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  }
}
EOF

    (cd "$tmp_dir" && eval "$cmd")
    rm -rf "$tmp_dir"
}

provider_rollback() {
    local backup_dir="$1"
    local project_id="${FIREBASE_PROJECT_ID:-}"
    local token="${FIREBASE_TOKEN:-}"
    local cmd="firebase deploy --only hosting"

    if [[ -n "$project_id" ]]; then
        cmd="$cmd --project $project_id"
    fi
    if [[ -n "$token" ]]; then
        cmd="$cmd --token $token"
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)
    cat > "$tmp_dir/firebase.json" <<EOF
{
  "hosting": {
    "public": "$backup_dir",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  }
}
EOF

    (cd "$tmp_dir" && eval "$cmd")
    rm -rf "$tmp_dir"
}

provider_setup_questions() {
    echo "# Firebase provider"
    echo "FIREBASE_PROJECT_ID="
    echo "FIREBASE_TOKEN="
}
