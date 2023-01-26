#!/usr/bin/env bash

COREMAPS_VERSION=$(jq -r .MapboxCoreMaps scripts/release/packager/versions.json)
TURF_VERSION=$(jq -r .Turf scripts/release/packager/versions.json)
LICENSE_HEADER=$(<scripts/license/LICENSE-header.md)

TURF_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/turf-swift/contents/LICENSE.md?ref=$TURF_VERSION" --jq ".content" | base64 --decode)
CORE_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/mapbox-gl-native-internal/contents/LICENSE-iOS.md?ref=maps-v$COREMAPS_VERSION" --jq ".content" | base64 --decode)


LICENSE_CONTENT="// This file is generated.
"$LICENSE_HEADER"

### turf-swift, https://github.com/mapbox/turf-swift

\`\`\`
"$TURF_LICENSE_CONTENT"
\`\`\`

---

"$CORE_LICENSE_CONTENT"
// End of generated file."

echo "$LICENSE_CONTENT"
