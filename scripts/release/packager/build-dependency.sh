#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

NAME=${1}
GIT_REPO_URL=${2}
VERSION=${3}
LINK_TYPE=${4}
SCHEME=${5:-"$NAME"}

mkdir .build
pushd .build

step "Clone $GIT_REPO_URL"
git clone "$GIT_REPO_URL" repo

step "Checkout tag: $VERSION"
git -C repo checkout "$VERSION"

step "Build $NAME"
../../create-xcframework.sh "$NAME" "$LINK_TYPE" "$SCHEME" "repo/$NAME.xcodeproj"

mv *.xcframework ../

popd
rm -rf .build
