#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

NAME=${1}
GIT_REPO_URL=${2}
VERSION=${3}
SCHEME=${4}

mkdir .build
pushd .build

step "Clone $GIT_REPO_URL"
git clone "$GIT_REPO_URL" repo

step "Checkout tag: $VERSION"
git -C repo checkout "$VERSION"

step "Build $NAME"
../../create-xcframework.sh "repo/$NAME.xcodeproj" "$SCHEME" "$NAME"

mv *.xcframework ../

popd
rm -rf .build
