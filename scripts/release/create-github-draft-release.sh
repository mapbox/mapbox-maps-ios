#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-github-draft-release.sh <version-without-v-prefix>
#

VERSION=$1

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
    # The following python one-liner parses the CircleCI config and takes executor called 'xcode-sdk-min' and then checkout the macos xcode version.
    # It's critical to have the same structure in CircleCI config in any place inside of file.
    XCODE_MIN_VERSION=$(python3 -c "import yaml,sys;print(yaml.safe_load(sys.stdin)['executors']['xcode-sdk-min']['macos']['xcode'])" < "$SCRIPT_DIR/../../.circleci/config.yml")

    CHANGELOG=$( ([[ $(command -v parse-changelog) ]] && parse-changelog CHANGELOG.md) || echo "<Compose changelog here>" )

    cat << EOF > notes.txt
### Dependency requirements:

* Compatible version of MapboxCoreMaps: \`$MAPBOX_COREMAPS_VERSION\`
* Compatible version of MapboxCommon: \`$MAPBOX_COMMON_VERSION\`
* Compatible version of Xcode: \`$XCODE_MIN_VERSION\`

### Changes

$CHANGELOG

### Dependencies
- [GL Native]($GL_NATIVE_RELEASE_URL)
- [Common]($COMMON_RELEASE_URL)

### Direct download

Link to download binaries (append your own Mapbox access token [scoped with \`DOWNLOADS:READ\`](https://account.mapbox.com/)):

\`\`\`
https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/$VERSION/MapboxMaps.zip?access_token=<access-token>
\`\`\`
EOF

    PRODUCTION_DOCS_PR_URL=$(GITHUB_TOKEN=$(mbx-ci github writer public token) \
        gh release create "v$VERSION" --repo mapbox/mapbox-maps-ios \
            --prerelease \
            --draft \
            --title "v$VERSION" \
            --notes-file notes.txt)

    info "New Release: $PRODUCTION_DOCS_PR_URL"
}

main
