#!/usr/bin/env bash

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "This script requires GITHUB_TOKEN variable to be set."
    exit 1
fi

COREMAPS_VERSION=$(jq -r .MapboxCoreMaps scripts/release/packager/versions.json)
TURF_VERSION=$(jq -r .Turf scripts/release/packager/versions.json)
MAPS_SDK_VERSION=$(jq -r .version Sources/MapboxMaps/MapboxMaps.json)
LICENSE_HEADER=$(m4 -D __MAPS_SDK_VERSION__="$MAPS_SDK_VERSION" scripts/license/LICENSE-header.md)

TURF_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/turf-swift/contents/LICENSE.md?ref=$TURF_VERSION" --jq ".content" | base64 --decode)
CORE_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/mapbox-gl-native-internal/contents/LICENSE-iOS.md?ref=maps-v$COREMAPS_VERSION" --jq ".content" | base64 --decode)


LICENSE_CONTENT="<!-- This file is generated. -->
"$LICENSE_HEADER"

### turf-swift, https://github.com/mapbox/turf-swift

\`\`\`
"$TURF_LICENSE_CONTENT"
\`\`\`

---

"$CORE_LICENSE_CONTENT"
<!-- End of generated file. -->"

echo "$LICENSE_CONTENT"
