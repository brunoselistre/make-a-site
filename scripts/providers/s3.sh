provider_name="s3"

provider_preflight() {
    if ! command -v aws &>/dev/null; then
        echo "ERROR: AWS CLI is not installed" >&2
        return 1
    fi
    if [[ -z "$S3_BUCKET" ]]; then
        echo "ERROR: S3_BUCKET must be set" >&2
        return 1
    fi
    if ! aws s3 ls "s3://$S3_BUCKET" &>/dev/null; then
        echo "ERROR: Cannot access S3 bucket $S3_BUCKET" >&2
        return 1
    fi
}

provider_deploy() {
    local src_dir="${1:-./src}"
    local region="${AWS_REGION:-us-east-1}"
    local prefix="${S3_PREFIX:-}"
    if [[ -n "$prefix" ]]; then
        aws s3 sync "$src_dir" "s3://$S3_BUCKET/$prefix" --region "$region"
    else
        aws s3 sync "$src_dir" "s3://$S3_BUCKET/" --region "$region"
    fi
}

provider_rollback() {
    local backup_dir="$1"
    local region="${AWS_REGION:-us-east-1}"
    local prefix="${S3_PREFIX:-}"
    if [[ -n "$prefix" ]]; then
        aws s3 sync "$backup_dir" "s3://$S3_BUCKET/$prefix" --region "$region"
    else
        aws s3 sync "$backup_dir" "s3://$S3_BUCKET/" --region "$region"
    fi
}

provider_setup_questions() {
    echo "S3_BUCKET="
    echo "S3_PREFIX="
    echo "AWS_REGION=us-east-1"
}