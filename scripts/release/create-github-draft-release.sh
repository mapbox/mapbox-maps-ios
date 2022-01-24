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
    GITHUB_TOKEN=$(mbx-ci github reader token)
    export GITHUB_TOKEN

    VERSION_JSON_PATH="$SCRIPT_DIR/packager/versions.json"

    GL_NATIVE_RELEASE_URL=$(gh release view --repo mapbox/mapbox-gl-native-internal "maps-v$(jq -r .MapboxCoreMaps "$VERSION_JSON_PATH")" --json url -q .url)
    COMMON_RELEASE_URL=$(gh release view --repo mapbox/mapbox-sdk-common "v$(jq -r .MapboxCommon "$VERSION_JSON_PATH")" --json url -q .url)

    MAPBOX_COMMON_VERSION=$(jq -r .MapboxCommon "$VERSION_JSON_PATH")
    MAPBOX_COREMAPS_VERSION=$(jq -r .MapboxCoreMaps "$VERSION_JSON_PATH")

    CHANGELOG=$( ([[ $(command -v parse-changelog) ]] && parse-changelog CHANGELOG.md) || echo "<Compose changelog here>" )

    cat << EOF > notes.txt
### Dependency requirements:

* Compatible version of MapboxCoreMaps: \`$MAPBOX_COREMAPS_VERSION\`
* Compatible version of MapboxCommon: \`$MAPBOX_COMMON_VERSION\`
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
}

main
