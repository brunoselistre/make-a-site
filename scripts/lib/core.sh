#!/usr/bin/env bash

core_load_env() {
    local env_file="$1"
    if [[ ! -f "$env_file" ]]; then
        echo "ERROR: Environment file not found: $env_file" >&2
        return 1
    fi
    set -a
    source "$env_file"
    set +a
}

core_require_var() {
    local var_name="$1"
    local env_file="$2"
    local value
    value=$(eval echo "\$$var_name")
    if [[ -z "$value" ]]; then
        echo "ERROR: Required variable '$var_name' is not set in $env_file" >&2
        return 1
    fi
}

core_backup_src() {
    local src_dir="${1:-./src}"
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="backups/src-$timestamp"
    mkdir -p "$(dirname "$backup_dir")"
    cp -r "$src_dir" "$backup_dir"
    echo "$backup_dir"
}

core_smoke_test() {
    local site_url="$1"
    local max_time="${2:-30}"
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$max_time" "$site_url" 2>/dev/null)
    echo "$status_code"
}

core_list_backups() {
    local backups_root="${1:-./backups}"
    if [[ ! -d "$backups_root" ]]; then
        echo "No backups found"
        return 1
    fi
    ls -t "$backups_root" 2>/dev/null
}

core_select_backup() {
    local date_filter="${1:-}"
    local backups_root="${2:-./backups}"
    local backup_name
    if [[ -z "$date_filter" ]]; then
        backup_name=$(ls -t "$backups_root" | head -1)
    else
        backup_name=$(ls -t "$backups_root" | grep "$date_filter" | head -1)
    fi
    if [[ -z "$backup_name" ]]; then
        echo "ERROR: No backup found matching filter '$date_filter'" >&2
        return 1
    fi
    echo "$backup_name"
}

core_resolve_provider() {
    local provider_name="$1"
    local script_dir
    script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    local provider_path="$script_dir/providers/${provider_name}.sh"
    if [[ ! -f "$provider_path" ]]; then
        echo "ERROR: Provider '$provider_name' not found at $provider_path" >&2
        return 1
    fi
    echo "$provider_path"
}

core_print_summary() {
    local env="$1"
    local timestamp="$2"
    local backup_dir="$3"
    local site_url="$4"
    local http_status="$5"
    echo ""
    echo "=== Deployment Summary ==="
    echo "Environment: $env"
    echo "Timestamp:   $timestamp"
    echo "Backup:      $backup_dir"
    echo "URL:         $site_url"
    echo "HTTP Status: $http_status"
    echo "======================="
    echo ""
}

core_print_rollback_summary() {
    local env="$1"
    local target="$2"
    local site_url="$3"
    local http_status="$4"
    echo ""
    echo "=== Rollback Summary ==="
    echo "Environment: $env"
    echo "Rollback to: $target"
    echo "URL:         $site_url"
    echo "HTTP Status: $http_status"
    echo "======================="
    echo ""
}