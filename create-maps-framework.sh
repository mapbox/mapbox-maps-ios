#!/usr/bin/env bash
# Usage: ./create-maps-framework.sh <Path to zip>

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }

function lipo_func {
  step "Lipo-ing singular framework for ${1}.framework"
  mkdir ${1}.framework
  cp -R artifact/${1}.xcframework/ios-arm64/${1}.framework/Headers ${1}.framework
  cp -R artifact/${1}.xcframework/ios-arm64/${1}.framework/Modules ${1}.framework
  cp artifact/${1}.xcframework/ios-arm64/${1}.framework/Info.plist ${1}.framework

  lipo artifact/${1}.xcframework/ios-x86_64-simulator/${1}.framework/${1} -thin x86_64 -output ${1}-x86_64

  lipo -create artifact/${1}.xcframework/ios-arm64/${1}.framework/${1} ${1}-x86_64 -output ${1}.framework/${1}
  step "Lipo-ing ${1} was successful!"
}

trap finish EXIT

if [ -z "$1" ]
  then
    echo "No Path to framework zip"
    return 1
fi

PATH_TO_ZIP=${1}

rm -rf artifacts
mkdir artifacts
cd artifacts

mv ${PATH_TO_ZIP} ./
unzip mapbox-maps-ios.zip

# lipo dependencies
step "Lipo-ing singular framework for dependencies"
lipo_func "MapboxCoreMaps"
lipo_func "MapboxCommon"
lipo_func "MapboxMobileEvents"
lipo_func "Turf"

step "Lipo-ing dependencies was successful!"

step "Lipo-ing the Maps SDK"
mkdir MapboxMaps.framework
cp -R artifact/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/Headers MapboxMaps.framework
cp -R artifact/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/Modules MapboxMaps.framework
cp artifact/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/Info.plist MapboxMaps.framework

lipo -create artifact/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/MapboxMaps artifact/MapboxMaps.xcframework/ios-x86_64-simulator/MapboxMaps.framework/MapboxMaps -output MapboxMaps.framework/MapboxMaps
step "Lipo-ing Maps was successful!"

# Clean up directory
rm -rf artifact MapboxCommon-x86_64 MapboxCoreMaps-x86_64 MapboxMobileEvents-x86_64 Turf-x86_64