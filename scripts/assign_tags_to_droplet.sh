#!/bin/bash -e

# ============================================================================================
# Assigns/removes tags to Droplet
#
# To add tags, just call:
# $ ./scripts/assign_tags_to_droplet.sh YOUR-DROPLET-ID tag1 tag2 tag3
#
# To change tags, just call:
# $ ./scripts/assign_tags_to_droplet.sh YOUR-DROPLET-ID tag1
#
# To untag all assigned tags, just call:
# $ ./scripts/assign_tags_to_droplet.sh YOUR-DROPLET-ID
#
# One important notice: this script does NOT delete tags, it just remove Droplet from the tag
# (https://developers.digitalocean.com/documentation/v2/#untag-a-resource)
# ============================================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DROPLET_ID=$1
shift
readonly TAGS=("$@")

# Imports $TF_VAR_digitalocean_api_token
source "$SCRIPT_DIR/../local_vars"


function create_tag {
    local readonly tag_id="$1"

    curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TF_VAR_digitalocean_api_token" \
        -d "{\"name\":\"$tag_id\"}" \
        "https://api.digitalocean.com/v2/tags"
}

function droplet_tags {
    local response=$(curl -s -X GET \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $TF_VAR_digitalocean_api_token" \
         "https://api.digitalocean.com/v2/droplets/${DROPLET_ID}" | jq -r ".droplet.tags[]")
    IFS=$'\n' sorted=($(sort <<<"${response[*]}"))
    unset IFS
    echo ${sorted[@]}
}

function untag_droplet {
    local readonly tag_id="$1"
    curl -s -X DELETE \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TF_VAR_digitalocean_api_token" \
        -d "{\"resources\":[{\"resource_id\": \"${DROPLET_ID}\", \"resource_type\": \"droplet\"}]}" \
        "https://api.digitalocean.com/v2/tags/${tag_id}/resources"
}

function assign_tag_to_droplet {
    local readonly tag_id="$1"

    curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TF_VAR_digitalocean_api_token" \
        -d "{\"resources\":[{\"resource_id\": \"${DROPLET_ID}\", \"resource_type\": \"droplet\"}]}" \
        "https://api.digitalocean.com/v2/tags/${tag_id}/resources"
}

readonly EXISTING_TAGS=(`droplet_tags`)
if [ "${#TAGS[@]}" -eq 0 ]; then
    echo "No tags provided. That means we should do untag for all Droplet:${DROPLET_ID} tags"
    for tag in "${EXISTING_TAGS[@]}"; do
        echo "Remove tag \"${tag}\" from Droplet:${DROPLET_ID}"
        untag_droplet "$tag"
    done
    exit 0
fi

# Uncomment for the debug
# echo -e "Existing tags:\t${EXISTING_TAGS[@]}"

# Calculate the difference between passed and existing tags
if [[ "${#EXISTING_TAGS[@]}" -ne 0 ]]; then
    ADD_TAGS=(`echo ${TAGS[@]} ${EXISTING_TAGS[@]} ${EXISTING_TAGS[@]} | tr ' ' '\n' | sort | uniq -u `)
    REMOVE_TAGS=(`echo ${EXISTING_TAGS[@]} ${TAGS[@]} ${TAGS[@]} | tr ' ' '\n' | sort | uniq -u `)
else
    ADD_TAGS=("${TAGS[@]}")
    declare -a REMOVE_TAGS
fi

if [ "${#ADD_TAGS[@]}" -gt 0 ]; then
    echo -e "\nNext tags will be added to Droplet:${DROPLET_ID}:\t${ADD_TAGS[@]}"

    for tag in "${ADD_TAGS[@]}"; do
        echo "Assign tag \"${tag}\" to Droplet:${DROPLET_ID}"
        create_tag "${tag}"
        assign_tag_to_droplet "${tag}"
    done
else
    echo "Nothing to add."
fi

if [ "${#REMOVE_TAGS[@]}" -gt 0 ]; then
    echo -e "\nNext tags will be removed from the Droplet:${DROPLET_ID}:\t${REMOVE_TAGS[@]}"
    
    for tag in "${REMOVE_TAGS[@]}"; do
        echo "Remove tag \"${tag}\" from Droplet:${DROPLET_ID}"
        untag_droplet "$tag"
    done
else
    echo "Nothing to remove"
fi
exit 0