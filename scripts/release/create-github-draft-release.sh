#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-github-draft-release.sh <version-without-v-prefix> <xcode-min-version> <github-reader-token> <github-writer-token>
#

VERSION=$1
XCODE_MIN_VERSION=$2
GITHUB_TOKEN=$3
GITHUB_WRITER_TOKEN=$4

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

main() {
    export GITHUB_TOKEN

    VERSION_JSON_PATH="$SCRIPT_DIR/packager/versions.json"

    MAPBOX_COMMON_VERSION=$(jq -r .MapboxCommon "$VERSION_JSON_PATH")
    MAPBOX_COREMAPS_VERSION=$(jq -r .MapboxCoreMaps "$VERSION_JSON_PATH")

    CHANGELOG=$( ([[ $(command -v parse-changelog) ]] && parse-changelog CHANGELOG.md) || echo "<Compose changelog here>" )

    cat << EOF > notes.txt
### Changes

$CHANGELOG

### Dependencies
* Update MapboxCommon to \`$MAPBOX_COMMON_VERSION\`.
* Update MapboxCoreMaps to \`$MAPBOX_COREMAPS_VERSION\`.

### Dependency requirements:
* Compatible version of Xcode: \`$XCODE_MIN_VERSION\`
EOF

    MAIN_RELEASE_URL=$(GITHUB_TOKEN=$GITHUB_WRITER_TOKEN \
        gh release create "v$VERSION" --repo mapbox/mapbox-maps-ios \
            --prerelease \
            --draft \
            --title "v$VERSION" \
            --notes-file notes.txt)

    info "New Release: $MAIN_RELEASE_URL"

    if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+- ]]; then
        PRERELEASE_FLAG="--prerelease"
    else
        PRERELEASE_FLAG=""
    fi

    BINARY_RELEASE_URL=$(GITHUB_TOKEN=$GITHUB_WRITER_TOKEN \
        gh release create "v$VERSION" --repo mapbox/mapbox-maps-ios-binary \
            $PRERELEASE_FLAG \
            --title "v$VERSION" \
            --notes "📖 For release notes and changelog, see: [mapbox-maps-ios v$VERSION](https://github.com/mapbox/mapbox-maps-ios/releases/tag/v$VERSION)")

    info "Binary Release: $BINARY_RELEASE_URL"
}

main
