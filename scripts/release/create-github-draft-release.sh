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

# Prints "draft" or "published" for each release with the tag, nothing if none.
# Lists via API because `gh release view <tag>` doesn't find drafts.
release_states() {
    GITHUB_TOKEN=$GITHUB_WRITER_TOKEN gh api "repos/$1/releases?per_page=100" --paginate \
        --jq ".[] | select(.tag_name == \"$VERSION\") | if .draft then \"draft\" else \"published\" end" || {
        error "Failed to list releases in $1"
        exit 1
    }
}

main() {
    export GITHUB_TOKEN

    MAIN_STATES=$(release_states mapbox/mapbox-maps-ios)
    if [[ -z "$MAIN_STATES" ]]; then
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
            gh release create "$VERSION" --repo mapbox/mapbox-maps-ios \
                --verify-tag \
                --prerelease \
                --draft \
                --title "v$VERSION" \
                --notes-file notes.txt)

        info "New Release: $MAIN_RELEASE_URL"
    else
        warning "Release $VERSION already exists in mapbox/mapbox-maps-ios ($(paste -sd, - <<< "$MAIN_STATES")), skipping. Its notes are not updated."
    fi

    if [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+- ]]; then
        PRERELEASE_FLAG="--prerelease"
    else
        PRERELEASE_FLAG=""
    fi

    BINARY_STATES=$(release_states mapbox/mapbox-maps-ios-binary)
    if grep -qx draft <<< "$BINARY_STATES"; then
        error "Release $VERSION in mapbox/mapbox-maps-ios-binary is a draft, but this script publishes it. Publish or delete it and rerun."
        exit 1
    elif [[ -n "$BINARY_STATES" ]]; then
        warning "Release $VERSION is already published in mapbox/mapbox-maps-ios-binary, skipping"
    else
        BINARY_RELEASE_URL=$(GITHUB_TOKEN=$GITHUB_WRITER_TOKEN \
            gh release create "$VERSION" --repo mapbox/mapbox-maps-ios-binary \
                --verify-tag \
                $PRERELEASE_FLAG \
                --title "v$VERSION" \
                --notes "📖 For release notes and changelog, see: [mapbox-maps-ios v$VERSION](https://github.com/mapbox/mapbox-maps-ios/releases/tag/$VERSION)")

        info "Binary Release: $BINARY_RELEASE_URL"
    fi
}

main
