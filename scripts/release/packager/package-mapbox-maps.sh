#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

step "Reading from versions.json"

CORE_VERSION=$(jq -r '.MapboxCoreMaps' ./versions.json)
COMMON_VERSION=$(jq -r '.MapboxCommon' ./versions.json)
TELEMETRY_VERSION=$(jq -r '.MapboxMobileEvents' ./versions.json)
TURF_VERSION=$(jq -r '.Turf' ./versions.json)

rm -rf artifacts
mkdir artifacts

step "Running download-dependency-xcframeworks.sh"
sh download-dependency-xcframeworks.sh ${CORE_VERSION} ${COMMON_VERSION} ${TELEMETRY_VERSION} artifacts

step "Running create-turf-xcframework.sh"
sh create-turf-xcframework.sh ${TURF_VERSION} artifacts

step "Creating MapboxMapsPackager.xcodeproj"
xcodegen -p artifacts/

step "Running create-mapbox-maps-xcframework.sh"
cd artifacts
sh ../create-mapbox-maps-xcframework.sh
cd ..
