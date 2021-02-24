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
pushd artifacts

step 'Installing Dependencies'
../download-dependency.sh mapbox-common MapboxCommon "$COMMON_VERSION"
../download-dependency.sh mobile-maps-core MapboxCoreMaps.xcframework-dynamic "$CORE_VERSION"
../build-dependency.sh MapboxMobileEvents 'https://github.com/mapbox/mapbox-events-ios.git' "$MME_VERSION" MapboxMobileEvents
../build-dependency.sh Turf 'https://github.com/mapbox/turf-swift.git' "$TURF_VERSION" "Turf iOS"

step 'Creating MapboxMaps.xcodeproj'
mkdir .xcode
cp ../project.yml .xcode/
pushd .xcode
ln -s ../../../../../Sources
ln -s ../../../../../Mapbox/Configurations
xcodegen
popd

step 'Building MapboxMaps.xcframework'
../create-xcframework.sh .xcode/MapboxMaps.xcodeproj MapboxMaps MapboxMaps
rm -rf .xcode

popd

step 'Add License and README to bundle'
cp ../../../LICENSE.md artifacts/
cp ../README.md artifacts/

step 'Zip Bundle'
zip -r MapboxMaps-dynamic.zip artifacts

step 'Delete Artifacts Directory'
rm -rf artifacts