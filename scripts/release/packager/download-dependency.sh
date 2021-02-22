#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

XCFRAMEWORK_NAME=${1}
SDK_NAME=${2}
ARTIFACT_NAME=${3}
VERSION=${4}
ARTIFACTS_DIRECTORY=${5}

pushd ${ARTIFACTS_DIRECTORY}

step "Download $XCFRAMEWORK_NAME.xcframework from https://api.mapbox.com/downloads/v2/$SDK_NAME/releases/ios/packages/$VERSION/$ARTIFACT_NAME.zip"
curl -n "https://api.mapbox.com/downloads/v2/$SDK_NAME/releases/ios/packages/$VERSION/$ARTIFACT_NAME.zip" --output "$XCFRAMEWORK_NAME.zip"

step 'Unzipping...'
mkdir "$XCFRAMEWORK_NAME"
unzip "$XCFRAMEWORK_NAME.zip" -d "$XCFRAMEWORK_NAME"
rm -rf "$XCFRAMEWORK_NAME.zip"

popd
