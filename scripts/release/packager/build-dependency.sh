#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

XCFRAMEWORK_NAME=${1}
GIT_REPO_URL=${2}
VERSION=${3}
SCHEME=${4}
ARTIFACTS_DIRECTORY=${5}

pushd ${ARTIFACTS_DIRECTORY}

step "Clone $GIT_REPO_URL"
git clone "$GIT_REPO_URL" "${XCFRAMEWORK_NAME}-repo"

pushd "$XCFRAMEWORK_NAME-repo"
step "Checkout tag: $VERSION"
git checkout "$VERSION"
popd

step "Build $XCFRAMEWORK_NAME"
mkdir "$XCFRAMEWORK_NAME"
pushd "$XCFRAMEWORK_NAME"
../../create-xcframework.sh "../$XCFRAMEWORK_NAME-repo/$XCFRAMEWORK_NAME.xcodeproj" "$SCHEME" "$XCFRAMEWORK_NAME"
popd

step 'Delete git repo'
rm -rf "${XCFRAMEWORK_NAME}-repo"

popd
