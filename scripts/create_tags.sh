#!/bin/bash -ex

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Importing $TF_VAR_digitalocean_api_token.
# Actually, you can pass $TF_VAR_digitalocean_api_token value along with list of tags.
source "$SCRIPT_DIR/../local_vars"

api_url="https://api.digitalocean.com/v2/tags"

function create_tag {
    local readonly tag_id="$1"

    curl --silent -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TF_VAR_digitalocean_api_token" \
        -d "{\"name\":\"$tag_id\"}" \
        "${api_url}"
}

for tag in "$@"; do
    create_tag "${tag}"
done