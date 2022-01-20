#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-github-draft-release.sh <tag name>
#

TAG=${1:-$VERSION}

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

main() {
    GL_NATIVE_RELEASE_URL=$(gh release view --repo mapbox/mapbox-gl-native-internal "maps-v$(jq -r .MapboxCoreMaps scripts/release/packager/versions.json)" --json url -q .url)
    COMMON_RELEASE_URL=$(gh release view --repo mapbox/mapbox-sdk-common "v$(jq -r .MapboxCommon scripts/release/packager/versions.json)" --json url -q .url)

    CHANGELOG=$( ([[ $(command -v parse-changelog) ]] && parse-changelog CHANGELOG.md) || echo "<Compose changelog here>" )

    cat << EOF > notes.txt
### Dependency requirements:

* Compatible version of MapboxCoreMaps:
* Compatible version of MapboxCommon:
* Compatible version of Xcode:
* Compatible version of macOS:

### Changes

$CHANGELOG

### Dependencies
- [GL Native]($GL_NATIVE_RELEASE_URL)
- [Common]($COMMON_RELEASE_URL)

### Direct download

Link to download binaries (append your own Mapbox access token [scoped with \`DOWNLOADS:READ\`](https://account.mapbox.com/)):

\`\`\`
https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/$TAG/MapboxMaps.zip?access_token=<access-token>
\`\`\`
EOF

    PRODUCTION_DOCS_PR_URL=$(GITHUB_TOKEN=$(mbx-ci github writer public token) \
        gh release create "$TAG" --repo mapbox/mapbox-maps-ios \
            --prerelease \
            --draft \
            --title "$TAG" \
            --notes-file notes.txt)

    info "New Release: $PRODUCTION_DOCS_PR_URL"

    # # Custom message for release
    # MESSAGE=

    # # Body that is passed to the POST request
    # BODY="{\"tag_name\":\"v$TAG\",\"target_commitish\":\"main\",\"name\":\"v$TAG\",\"body\":\"$MESSAGE\",\"draft\":true,\"prerelease\":true}"

    # # Performing the request using github API
    # CURL_RESULT=0
    # HTTP_CODE=$(curl $URL \
    #     -H "Authorization: token $GITHUB_TOKEN" \
    #     -H "Accept: application/vnd.github.v3+json" \
    #     -d "$BODY" -w "%{response_code}") || CURL_RESULT=$?

    # if [[ $CURL_RESULT != 0 ]]; then
    #     echo "Failed to create draft release (curl error: $CURL_RESULT)"
    #     exit $CURL_RESULT
    # fi

    # echo "Result from draft release creation: $HTTP_CODE"
}

main