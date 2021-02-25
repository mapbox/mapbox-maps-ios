#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/update-dependency-manager-manifests.sh <maps version number>
#

MAPS_VERSION=${1}
COMMON_VERSION=`awk -F'MapboxCommon-ios.json" ==' '{ printf $2 }' Cartfile`
CORE_VERSION=`awk -F'MapboxCoreMaps-dynamic.json" ==' '{ printf $2 }' Cartfile`

#
# Checkout the release branch
#
git fetch origin main
git checkout Release/v${MAPS_VERSION}

# Update Package.swift
sed -i '' s/"mapbox-common-ios.git\", .exact(\".*\")"/"mapbox-common-ios.git\", .exact(\"${COMMON_VERSION}\")"/ Package.swift
sed -i '' s/"mapbox-core-maps-ios.git\", .exact(\".*\")"/"mapbox-core-maps-ios.git\", .exact(\"${CORE_VERSION}\")"/ Package.swift

# Update MapboxMaps.podspec
sed -i '' s/"maps_version = '.*'"/"maps_version = '${MAPS_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCommon', '.*'"/"m.dependency 'MapboxCommon', '${COMMON_VERSION}'"/ MapboxMaps.podspec
sed -i '' s/"m.dependency 'MapboxCoreMaps', '.*'"/"m.dependency 'MapboxCoreMaps', '${CORE_VERSION}'"/ MapboxMaps.podspec

#
# Commit to the release branch
#
git add Package.swift MapboxMaps.podspec
git commit -m "Update SPM configs for ${MAPS_VERSION} release"
git push
