#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

step 'Reading from versions.json'

CORE_VERSION=$(jq -r '.MapboxCoreMaps' ./versions.json)
COMMON_VERSION=$(jq -r '.MapboxCommon' ./versions.json)
MME_VERSION=$(jq -r '.MapboxMobileEvents' ./versions.json)
TURF_VERSION=$(jq -r '.Turf' ./versions.json)

step 'Cleaning up dependencies directory'
rm -rf artifacts
mkdir artifacts

step 'Installing Dependencies'
./download-dependency.sh MapboxCommon mapbox-common MapboxCommon "$COMMON_VERSION" artifacts
./download-dependency.sh MapboxCoreMaps mobile-maps-core MapboxCoreMaps.xcframework "$CORE_VERSION" artifacts
./build-dependency.sh MapboxMobileEvents 'https://github.com/mapbox/mapbox-events-ios.git' "$MME_VERSION" MapboxMobileEvents artifacts
./build-dependency.sh Turf 'https://github.com/mapbox/turf-swift.git' "$TURF_VERSION" "Turf iOS" artifacts

step 'Creating MapboxMapsPackager.xcodeproj'
xcodegen -p artifacts/

step 'Running create-mapbox-maps-xcframework.sh'
cd artifacts
../create-xcframework.sh MapboxMapsPackager.xcodeproj MapboxMaps MapboxMaps
cd ..
