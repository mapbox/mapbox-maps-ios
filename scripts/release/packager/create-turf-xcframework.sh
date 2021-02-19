#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

GIT_TAG=${1}
ARTIFACTS_DIRECTORY=${2}

cd ${ARTIFACTS_DIRECTORY}

step "Clone turf-swift"
git clone https://github.com/mapbox/turf-swift.git
cd turf-swift

step "Checkout tag: ${GIT_TAG}"
git checkout ${GIT_TAG}

step "Run scripts/create-xcframework.sh"
sh scripts/create-xcframework.sh

step "Copy resulting xcframework"
cd ..
mkdir Turf
cp -r turf-swift/Build/Turf.xcframework Turf

step "Delete turf-swift repo"
rm -rf turf-swift

cd ..