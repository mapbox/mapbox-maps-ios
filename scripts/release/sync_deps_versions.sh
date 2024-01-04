#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_ROOT_DIR="$SCRIPT_DIR/../../"

UTILS_PATH="$SCRIPT_DIR/../utils.sh"
# shellcheck source=../utils.sh
source "$UTILS_PATH"

VERSIONS_JSON_PATH="$SCRIPT_DIR/packager/versions.json"

pushd "$REPO_ROOT_DIR" > /dev/null
brew_install_if_needed jq

CORE_MAPS_VERSION=$(jq -r .MapboxCoreMaps "$VERSIONS_JSON_PATH")
COMMON_VERSION=$(jq -r .MapboxCommon "$VERSIONS_JSON_PATH")

info "Update dependencies in MapboxMaps.podspec"
sed -i '' -E "s/(m.dependency.*MapboxCoreMaps.*, ).*/\1'$CORE_MAPS_VERSION'/" MapboxMaps.podspec
sed -i '' -E "s/(m.dependency.*MapboxCommon.*, ).*/\1'$COMMON_VERSION'/" MapboxMaps.podspec

info "Update dependencies in Package.swift"
sed -i '' -E "s/(.*MapsDependency.coreMaps.*):.*/\1: \"$CORE_MAPS_VERSION\"\)/"  Package.swift
sed -i '' -E "s/(.*MapsDependency.common.*):.*/\1: \"$COMMON_VERSION\"\)/"  Package.swift

info "Resolve SPM dependencies"
swift package update
xcodebuild -resolvePackageDependencies -workspace Apps/Apps.xcworkspace -scheme MapboxMaps

finish "Updated dependency versions"
