#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/update-spm-manifest.sh <maps version number> <common version number> <core version number> <maps xcframework checksum> <branch name>
#

MAPS_VERSION=${1}
COMMON_VERSION=${2//v/}
CORE_VERSION=${3//v/}
CHECKSUM=${4}
BRANCH_NAME=${5} #TODO: Should be updated for when it is added to automation
GITHUB_TOKEN=$(./scripts/get_token.js)

TMPDIR=`mktemp -d`

git checkout -b ${BRANCH_NAME}
git pull origin main

# Update Package.swift
sed -i '' s/"let version = \".*\""/"let version = \"${MAPS_VERSION}\""/ Package.swift
sed -i '' s/"let checksum = \".*\""/"let checksum = \"${CHECKSUM}\""/ Package.swift
sed -i '' s/"mapbox-common-ios.git\", .exact(\".*\")"/"mapbox-common-ios.git\", .exact(\"${COMMON_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-core-maps-ios.git\", .exact(\".*\")"/"mapbox-core-maps-ios.git\", .exact(\"${CORE_VERSION}\")"/ Package.swift

#
# Commit to a branch
#
git add -A
git commit -m "Update SPM configs for ${BRANCH_NAME} release"
# git push --set-upstream origin ${BRANCH_NAME}
git push origin ${BRANCH_NAME} #TODO: Update, this works great for local, but should be updated for automation

#
# Create PR
#
# git config --global user.email "maps_sdk_ios@mapbox.com"
# git config --global user.name "Release SDK bot for Maps SDK iOS team"

TITLE="Update SPM configs for ${BRANCH_NAME} release"
URL="https://api.github.com/repos/mapbox/mapbox-maps-ios/pulls"
BODY="{\"head\":\"${BRANCH_NAME}\",\"base\":\"main\",\"title\":\"${TITLE}\",\"body\":\"\"}"

CURL_RESULT=0
HTTP_CODE=$(curl ${URL} \
    --write-out %{http_code} \
    --silent \
    --output /dev/null \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "${BODY}" -w "%{response_code}") || CURL_RESULT=$?

if [[ ${CURL_RESULT} != 0 ]]; then
    echo "Failed to create PR (curl error: ${CURL_RESULT})"
    exit $CURL_RESULT
fi
if [[ ${HTTP_CODE} != "201" ]]; then
    echo "Failed to create PR (http code: ${HTTP_CODE})"
    exit 1
fi