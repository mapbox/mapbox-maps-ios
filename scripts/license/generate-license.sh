#!/usr/bin/env bash

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "This script requires GITHUB_TOKEN variable to be set."
    exit 1
fi

COREMAPS_VERSION=$(jq -r .MapboxCoreMaps scripts/release/packager/versions.json)

if [[ $COREMAPS_VERSION = *"SNAPSHOT"* ]]; then
    # Skipping license check for GL Native snapshots.
    exit 0
fi

TURF_VERSION=$(jq -r .Turf scripts/release/packager/versions.json)
MAPS_SDK_VERSION=$(jq -r .version Sources/MapboxMaps/MapboxMaps.json)
CURRENT_YEAR=$(date +%Y)

TURF_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/turf-swift/contents/LICENSE.md?ref=v$TURF_VERSION" --jq ".content" | base64 --decode)
CORE_LICENSE=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/mapbox-gl-native-internal/contents/LICENSE-iOS.md?ref=maps-v$COREMAPS_VERSION" --jq ".content" | base64 --decode)

m4  -D __MAPS_SDK_VERSION__="$MAPS_SDK_VERSION" \
    -D __TURF_LICENSE_CONTENT__="$TURF_LICENSE_CONTENT" \
    -D __CORE_LICENSE__="$CORE_LICENSE" \
    -D __YEAR__="$CURRENT_YEAR" \
    scripts/license/LICENSE-template.md
