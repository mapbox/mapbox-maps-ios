#!/usr/bin/env bash

## This scripts uses MapboxMaps.zip artifact created by the packager script to validate the customer will be able to
## user our binary frameworks on their version of Xcode.
## It should be run on the minimal supported version of Xcode.
## TODO: Merge this script with validate-integrations.sh

set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

PACKAGE_PATH=${1} # path to MapboxMaps.zip

step "unzip MapboxMaps.zip"

export DYNAMIC_ARTIFACTS_PATH="$SCRIPT_DIR/artifacts"
unzip -o -q "$PACKAGE_PATH" -d "$SCRIPT_DIR"

ls -la "$DYNAMIC_ARTIFACTS_PATH"

step "Generate Xcode project with Xcodegen"
pushd "$SCRIPT_DIR" > /dev/null || exit 1
MBX_TOKEN="$(cat ~/.mapbox)" xcodegen -s "project-base.yml"

step "Build DirectDynamicDownload scheme"
xcodebuild clean build -scheme "DirectDynamicDownload" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED='NO' COMPILER_INDEX_STORE_ENABLE=NO
