#!/bin/bash
set -x
set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

# Default values are set to facilitate local runs with the expectation that scriprt will be called from the packager directory.
LINK_TYPE=${1:-"dynamic"}
VERSIONS_JSON_PATH=$(realpath "${2:-"./versions.json"}")
CREATE_XCFRAMEWORK_SCRIPT=$(realpath "${3:-"./create-xcframework.sh"}")
XCODE_PROJECT_SPEC_PATH=$(realpath "${4:-"./project.yml"}")
MAPBOX_MAPS_DIR=$(realpath "${5:-"../../../../mapbox-maps-ios"}")
LICENSE_PATH=$(realpath "${6:-"../../../LICENSE.md"}")
ARCHIVE_OUTPUT_PATH=${7:-"MapboxMaps.zip"}

function build_from_git() {
    local NAME=${1}
    local GIT_REPO_URL=${2}
    local VERSION=${3}
    local LINK_TYPE=${4}
    local SCHEME=${5}
    local CREATE_XCFRAMEWORK_SCRIPT=${6}
    local ARTIFACTS_DIR=${7}

    step "Clone $GIT_REPO_URL"
    git clone "$GIT_REPO_URL" "$ARTIFACTS_DIR/$NAME"

    step "Checkout tag: $VERSION"
    git -C "$ARTIFACTS_DIR/$NAME" checkout "$VERSION"

    step "Build $NAME"
    "$CREATE_XCFRAMEWORK_SCRIPT" "$NAME" "$LINK_TYPE" "$SCHEME" "$ARTIFACTS_DIR/$NAME/$NAME.xcodeproj" Turf "$MAPBOX_MAPS_DIR/Sources/MapboxMaps/MapboxMaps.json" "$ARTIFACTS_DIR"

    step "Remove directory"
    rm -rf "$ARTIFACTS_DIR/${NAME:?}"
}

function download_binary() {
    local SDK_REGISTRY_NAME=${1}
    local SDK_REGISTRY_ARTIFACT=${2}
    local VERSION=${3}
    local ARTIFACTS_DIR=${4}
    local RELEASE_FOLDER="releases"

    mkdir .download

    if [[ ${VERSION} = *"SNAPSHOT"* ]]; then
        RELEASE_FOLDER="snapshots"
    fi

    step "Download dependency at https://api.mapbox.com/downloads/v2/$SDK_REGISTRY_NAME/$RELEASE_FOLDER/ios/packages/$VERSION/$SDK_REGISTRY_ARTIFACT.zip"
    curl -n "https://api.mapbox.com/downloads/v2/$SDK_REGISTRY_NAME/$RELEASE_FOLDER/ios/packages/$VERSION/$SDK_REGISTRY_ARTIFACT.zip" --output .download/tmp.zip

    step "Unzipping $SDK_REGISTRY_ARTIFACT.zip ..."
    unzip -q .download/tmp.zip -d .download
    mv .download/*.xcframework "$ARTIFACTS_DIR"

    rm -rf .download
}

step 'Reading from versions.json'
CORE_VERSION=$(jq -r '.MapboxCoreMaps' "$VERSIONS_JSON_PATH")
COMMON_VERSION=$(jq -r '.MapboxCommon' "$VERSIONS_JSON_PATH")
TURF_VERSION=$(jq -r '.Turf' "$VERSIONS_JSON_PATH")

step 'Cleaning up dependencies directory'
rm -rf artifacts
mkdir -p artifacts/.xcode

step 'Installing Dependencies'
if [ "$LINK_TYPE" = "dynamic" ]; then
    echo "Creating dynamic framework."
    COMMON_ARTIFACT=MapboxCommon
    CORE_ARTIFACT=MapboxCoreMaps.xcframework-dynamic
    README_PATH="$MAPBOX_MAPS_DIR/scripts/release/README-dynamic.md"
elif [ "$LINK_TYPE" = "static" ]; then
    echo "Creating static framework."
    COMMON_ARTIFACT=MapboxCommon-static
    CORE_ARTIFACT=MapboxCoreMaps.xcframework-static
    README_PATH="$MAPBOX_MAPS_DIR/scripts/release/README-static.md"
else
    echo "Error: Invalid link type: $LINK_TYPE"
    echo "Usage: $0 [dynamic|static]"
    exit 1
fi

download_binary mapbox-common "$COMMON_ARTIFACT" "$COMMON_VERSION" artifacts
download_binary mobile-maps-core "$CORE_ARTIFACT" "$CORE_VERSION" artifacts
build_from_git "Turf" "https://github.com/mapbox/turf-swift.git" "v$TURF_VERSION" "$LINK_TYPE" "Turf" "$CREATE_XCFRAMEWORK_SCRIPT" artifacts

step 'Creating MapboxMaps.xcodeproj'
cp "$XCODE_PROJECT_SPEC_PATH" artifacts/.xcode/

step 'Symlink MapboxMaps directory'
ln -s "$MAPBOX_MAPS_DIR" artifacts/.xcode
xcodegen --spec artifacts/.xcode/project.yml

step 'Building MapboxMaps.xcframework'
"$CREATE_XCFRAMEWORK_SCRIPT" 'MapboxMaps' "$LINK_TYPE" 'MapboxMaps' "artifacts/.xcode/MapboxMaps.xcodeproj" "MapboxMaps" "$MAPBOX_MAPS_DIR/Sources/MapboxMaps/MapboxMaps.json" artifacts
rm -rf .xcode

step 'Sign XCFrameworks'
codesign --timestamp -v --sign "Apple Distribution: Mapbox, Inc. (GJZR2MEM28)" "artifacts/Turf.xcframework" "artifacts/MapboxMaps.xcframework"
 
step 'Add License and README to bundle'
cp "$LICENSE_PATH" artifacts/LICENSE.md
cp "$README_PATH" artifacts/README.md

step 'Zip Bundle'
zip -qyr "$ARCHIVE_OUTPUT_PATH" artifacts

step 'Delete Artifacts Directory'
rm -rf artifacts