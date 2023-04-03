#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

SDK_REGISTRY_NAME=${1}
SDK_REGISTRY_ARTIFACT=${2}
VERSION=${3}
RELEASE_FOLDER="releases"

mkdir .download
pushd .download

if [[ ${VERSION} = *"SNAPSHOT"* ]]; then
    RELEASE_FOLDER="snapshots"
fi

step "Download dependency at https://api.mapbox.com/downloads/v2/$SDK_REGISTRY_NAME/$RELEASE_FOLDER/ios/packages/$VERSION/$SDK_REGISTRY_ARTIFACT.zip"
curl -n "https://api.mapbox.com/downloads/v2/$SDK_REGISTRY_NAME/$RELEASE_FOLDER/ios/packages/$VERSION/$SDK_REGISTRY_ARTIFACT.zip" --output tmp.zip

step "Unzipping $SDK_REGISTRY_ARTIFACT.zip ..."
unzip -q tmp.zip
mv ./*.xcframework ../

popd
rm -rf .download
