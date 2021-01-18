#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/get_latest_tag.sh
#

# Variables needed for github actions
GITHUB_TOKEN=$(./scripts/release/get_token.js)

# Set git config
git config --global user.email "maps_sdk_ios@mapbox.com"
git config --global user.name "Maps SDK github release bot"

# URL for where we are posting a new release
URL="https://api.github.com/repos/mapbox/mapbox-maps-ios/tags"

# Performing the request using github API
# CURL_RESULT=0
LATEST_TAG=$(curl ${URL} \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" | jq -r '.[0].name')

echo $LATEST_TAG