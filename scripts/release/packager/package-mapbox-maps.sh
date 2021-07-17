#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

LINK_TYPE=${1:-"dynamic"}

step 'Reading from versions.json'
CORE_VERSION=$(jq -r '.MapboxCoreMaps' ./versions.json)
COMMON_VERSION=$(jq -r '.MapboxCommon' ./versions.json)
MME_VERSION=$(jq -r '.MapboxMobileEvents' ./versions.json)
TURF_VERSION=$(jq -r '.Turf' ./versions.json)

step 'Cleaning up dependencies directory'
rm -rf artifacts
mkdir artifacts
pushd artifacts

step 'Installing Dependencies'
if [ "$LINK_TYPE" = "dynamic" ]; then
    COMMON_ARTIFACT=MapboxCommon
    CORE_ARTIFACT=MapboxCoreMaps.xcframework-dynamic
    ZIP_ARCHIVE_NAME="MapboxMaps.zip"
    README_PATH=../README-dynamic.md
elif [ "$LINK_TYPE" = "static" ]; then
    COMMON_ARTIFACT=MapboxCommon-static
    CORE_ARTIFACT=MapboxCoreMaps.xcframework-static
    ZIP_ARCHIVE_NAME="MapboxMaps-static.zip"
    README_PATH=../README-static.md
else
    echo "Error: Invalid link type: $LINK_TYPE"
    echo "Usage: $0 [dynamic|static]"
    exit 1
fi

../download-dependency.sh mapbox-common "$COMMON_ARTIFACT" "$COMMON_VERSION"
../download-dependency.sh mobile-maps-core "$CORE_ARTIFACT" "$CORE_VERSION"
../build-dependency.sh MapboxMobileEvents 'https://github.com/mapbox/mapbox-events-ios.git' "$MME_VERSION" "$LINK_TYPE"
../build-dependency.sh Turf 'https://github.com/mapbox/turf-swift.git' "$TURF_VERSION" "$LINK_TYPE" "Turf iOS"

step 'Creating MapboxMaps.xcodeproj'
mkdir .xcode
cp ../project.yml .xcode/
pushd .xcode
ln -s ../../../../../Sources
ln -s ../../../../../Configurations
xcodegen
popd

step 'Building MapboxMaps.xcframework'
../create-xcframework.sh MapboxMaps "$LINK_TYPE" MapboxMaps .xcode/MapboxMaps.xcodeproj
rm -rf .xcode

popd

step 'Add License and README to bundle'
cp ../../../LICENSE.md artifacts/
cp "$README_PATH" artifacts/README.md

step 'Zip Bundle'
zip -r "$ZIP_ARCHIVE_NAME" artifacts

step 'Delete Artifacts Directory'
rm -rf artifacts
