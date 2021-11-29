#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-github-draft-release.sh <tag name>
#

TAG=$1

# Variables needed for github actions
GITHUB_TOKEN=$(./scripts/release/get_token.js)

# Set git config
git config --global user.email "maps_sdk_ios@mapbox.com"
git config --global user.name "Maps SDK github release bot"

# URL for where we are posting a new release
URL="https://api.github.com/repos/mapbox/mapbox-maps-ios/releases"

# Custom message for release
MESSAGE="### Dependency requirements:\n\
\n\
* Compatible version of MapboxCoreMaps:\n\
* Compatible version of MapboxCommon:\n\
* Compatible version of Xcode:\n\
* Compatible version of macOS:\n\
\n\
### Changes\n\
\n\
<Compose changelog here>\n\
\n\
### Direct download\n\
\n\
Link to download binaries (append your own Mapbox access token [scoped with \`DOWNLOADS:READ\`](https://account.mapbox.com/)):\n\
\n\
\`\`\`\n\
https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/$TAG/MapboxMaps.zip?access_token=<access-token>\n\
\`\`\`"

# Body that is passed to the POST request
BODY="{\"tag_name\":\"v$TAG\",\"target_commitish\":\"main\",\"name\":\"v$TAG\",\"body\":\"$MESSAGE\",\"draft\":true,\"prerelease\":true}"

# Performing the request using github API
CURL_RESULT=0
HTTP_CODE=$(curl $URL \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "$BODY" -w "%{response_code}") || CURL_RESULT=$?

if [[ $CURL_RESULT != 0 ]]; then
    echo "Failed to create draft release (curl error: $CURL_RESULT)"
    exit $CURL_RESULT
fi

echo "Result from draft release creation: $HTTP_CODE"
