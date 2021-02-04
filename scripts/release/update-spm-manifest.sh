#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/update-spm-manifest.sh <maps version number> <maps xcframework checksum> <common version number> <core version number>
#

MAPS_VERSION=${1}
CHECKSUM=${2}
COMMON_VERSION=${3//v/}
CORE_VERSION=${4//v/}
EVENTS_VERSION=${5//v/}
TURF_VERSION=${6//v/}
GITHUB_TOKEN=$(./scripts/release/get_token.js)

#
# Checkout the release branch
#
git fetch origin main
git checkout Release/v${MAPS_VERSION}

# Update Package.swift
sed -i '' s/"let version = \".*\""/"let version = \"${MAPS_VERSION}\""/ Package.swift
sed -i '' s/"let checksum = \".*\""/"let checksum = \"${CHECKSUM}\""/ Package.swift
sed -i '' s/"mapbox-common-ios.git\", .exact(\".*\")"/"mapbox-common-ios.git\", .exact(\"${COMMON_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-core-maps-ios.git\", .exact(\".*\")"/"mapbox-core-maps-ios.git\", .exact(\"${CORE_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-events-ios.git\", .exact(\".*\")"/"mapbox-events-ios.git\", .exact(\"${EVENTS_VERSION}\")"/ Package.swift
sed -i '' s/"turf-swift.git\", .exact(\".*\")"/"turf-swift.git\", .exact(\"${TURF_VERSION}\")"/ Package.swift

# Update MapboxMaps.podspec
sed -i '' s/"maps_version = '.*'"/"maps_version = '${MAPS_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCommon', '.*'"/"m.dependency 'MapboxCommon', '${COMMON_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCoreMaps', '.*'"/"m.dependency 'MapboxCoreMaps', '${CORE_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxMobileEvents', '.*'"/"m.dependency 'MapboxMobileEvents', '${EVENTS_VERSION}'"/ MapboxMaps.podspec

#
# Commit to the release branch
#
git add Package.swift MapboxMaps.podspec
git commit -m "Update SPM configs for ${MAPS_VERSION} release"
git push
