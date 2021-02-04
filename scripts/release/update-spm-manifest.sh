#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/update-spm-manifest.sh <maps version number> <maps xcframework checksum> <common version number> <core version number>
#

MAPS_VERSION=${1}
CHECKSUM=${2}
COMMON_VERSION=${3//v/}
CORE_VERSION=${4//v/}
EVENTS_VERSION=${5//v/}
TURF_VERSION=${6//v/}
GITHUB_TOKEN=$(./scripts/release/get_token.js)

# Update Package.swift
sed -i '' s/"let version = \".*\""/"let version = \"${MAPS_VERSION}\""/ Package.swift
sed -i '' s/"let checksum = \".*\""/"let checksum = \"${CHECKSUM}\""/ Package.swift
sed -i '' s/"mapbox-common-ios.git\", .exact(\".*\")"/"mapbox-common-ios.git\", .exact(\"${COMMON_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-core-maps-ios.git\", .exact(\".*\")"/"mapbox-core-maps-ios.git\", .exact(\"${CORE_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-events-ios.git\", .exact(\".*\")"/"mapbox-events-ios.git\", .exact(\"${EVENTS_VERSION}\")"/ Package.swift
sed -i '' s/"turf-swift.git\", .exact(\".*\")"/"turf-swift.git\", .exact(\"${TURF_VERSION}\")"/ Package.swift

# Update MapboxCoreMaps.podspec
sed -i '' s/"maps_version = '.*'"/"maps_version = '${MAPS_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCommon', '.*'"/"m.dependency 'MapboxCommon', '${COMMON_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCoreMaps', '.*'"/"m.dependency 'MapboxCoreMaps', '${CORE_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxMobileEvents', '.*'"/"m.dependency 'MapboxMobileEvents', '${EVENTS_VERSION}'"/ MapboxMaps.podspec

#
# Commit to a branch
#
# git add -A
# git commit -m "Update SPM configs for ${MAPS_VERSION} release"

# TODO: Automate PR Creation when run on CI
# #
# # Create PR
# #
# git config --global user.email "maps_sdk_ios@mapbox.com"
# git config --global user.name "Release SDK bot for Maps SDK iOS team"

# TITLE="Update SPM configs for ${MAPS_VERSION} release"
# URL="https://api.github.com/repos/mapbox/mapbox-maps-ios/pulls"
# BODY="{\"head\":\"${BRANCH_NAME}\",\"base\":\"main\",\"title\":\"${TITLE}\",\"body\":\"\"}"

# CURL_RESULT=0
# HTTP_CODE=$(curl ${URL} \
#     --write-out %{http_code} \
#     --silent \
#     --output /dev/null \
#     -H "Authorization: token ${GITHUB_TOKEN}" \
#     -H "Accept: application/vnd.github.v3+json" \
#     -d "${BODY}" -w "%{response_code}") || CURL_RESULT=$?

# if [[ ${CURL_RESULT} != 0 ]]; then
#     echo "Failed to create PR (curl error: ${CURL_RESULT})"
#     exit $CURL_RESULT
# fi
# if [[ ${HTTP_CODE} != "201" ]]; then
#     echo "Failed to create PR (http code: ${HTTP_CODE})"
#     exit 1
# fi