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

set -euo pipefail
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

    PRODUCTION_DOCS_PR_URL=$(GITHUB_TOKEN=$GITHUB_WRITER_TOKEN \
        gh release create "v$VERSION" --repo mapbox/mapbox-maps-ios \
            --prerelease \
            --draft \
            --title "v$VERSION" \
            --notes-file notes.txt)

    info "New Release: $PRODUCTION_DOCS_PR_URL"
}

main
