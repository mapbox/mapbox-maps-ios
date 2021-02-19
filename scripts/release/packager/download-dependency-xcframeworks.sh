#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

CORE_VERSION=${1}
COMMON_VERSION=${2}
TELEMETRY_VERSION=${3}
ARTIFACTS_DIRECTORY=${4}

step "Cleaning up dependencies directory"
rm -rf ${ARTIFACTS_DIRECTORY}
mkdir ${ARTIFACTS_DIRECTORY}

cd ${ARTIFACTS_DIRECTORY}

step "Download MapboxCommon.xcframework from https://api.mapbox.com/downloads/v2/mapbox-common/releases/ios/packages/${COMMON_VERSION}/MapboxCommon.zip"
curl -n https://api.mapbox.com/downloads/v2/mapbox-common/releases/ios/packages/${COMMON_VERSION}/MapboxCommon.zip --output Common.zip

step "Download MapboxMobileEvents.xcframework from https://api.mapbox.com/downloads/v2/mobile-events/releases/ios/packages/${TELEMETRY_VERSION}/MapboxMobileEvents.xcframework.zip"
curl -n https://api.mapbox.com/downloads/v2/mobile-events/releases/ios/packages/${TELEMETRY_VERSION}/MapboxMobileEvents.xcframework.zip --output Telemetry.zip

step "Download MapboxCoreMaps.xcframework from https://api.mapbox.com/downloads/v2/mobile-maps-core/releases/ios/packages/${CORE_VERSION}/MapboxCoreMaps.xcframework.zip"
curl -n https://api.mapbox.com/downloads/v2/mobile-maps-core/releases/ios/packages/${CORE_VERSION}/MapboxCoreMaps.xcframework.zip --output Core.zip

step "Download Turf.xcframework from https://api.mapbox.com/downloads/v2/turf-swift/releases/ios/packages/2.0.0-alpha.1/Turf.xcframework.zip"
curl -n https://api.mapbox.com/downloads/v2/turf-swift/releases/ios/packages/2.0.0-alpha.1/Turf.xcframework.zip --output Turf.zip

step "Unzipping.."

mkdir Common
unzip Common.zip -d Common
rm -rf Common.zip

mkdir Telemetry
unzip Telemetry.zip -d Telemetry
rm -rf Telemetry.zip

mkdir Core
unzip Core.zip -d Core
rm -rf Core.zip

mkdir Turf
unzip Turf.zip -d Turf
rm -rf Turf.zip

cd ..