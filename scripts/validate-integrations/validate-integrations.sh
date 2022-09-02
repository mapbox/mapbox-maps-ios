#!/usr/bin/env bash
set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"
TMP_ROOT=$(mktemp -d)
ARTIFACTS_ROOT=${DEFAULT_ARTIFACTS_DIR:-$TMP_ROOT}

# shellcheck source=../utils.sh
source "$UTILS_PATH"

VERSION_RULE=0
BRANCH_RULE=0
PRIVATE_REPO_RULE=0
ENABLE_DIRECT_DOWNLOADS_VALIDATION=1
EXCLUSIVE_DIRECT_DOWNLOADS_VALIDATION=0

main() {
    PROJECTS_TO_TEST=("SwiftPackageManagerIntegration" "CocoaPodsIntegration")
    if [[ $VERSION_RULE == 1 && $ENABLE_DIRECT_DOWNLOADS_VALIDATION == 1 ]]; then
        step "Download MapboxMaps binaries"

        if [[ $EXCLUSIVE_DIRECT_DOWNLOADS_VALIDATION == 1 ]]; then
            PROJECTS_TO_TEST=("DirectDynamicDownload")
        else
            PROJECTS_TO_TEST+=("DirectDynamicDownload")
        fi
        DYNAMIC_ARTIFACTS_DOWNLOAD_PATH="$TMP_ROOT/Dynamic/"
        curl -n "https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/$MAPS_VERSION/MapboxMaps.zip" -o "$TMP_ROOT/MapboxMaps.zip"
        unzip -q "$TMP_ROOT/MapboxMaps.zip" -d "$DYNAMIC_ARTIFACTS_DOWNLOAD_PATH"

        export DYNAMIC_ARTIFACTS_PATH="$DYNAMIC_ARTIFACTS_DOWNLOAD_PATH/artifacts"
    fi

    step "Generate Xcode project with Xcodegen"
    pushd "$SCRIPT_DIR" > /dev/null || exit 1
    MBX_TOKEN="$(cat ~/.mapbox)" xcodegen

    if [[ $BRANCH_RULE == 1 ]]; then
        # Escape '/' and '\' to make Bash and Sed happy
        if [[ $PRIVATE_REPO_RULE == 1 ]]; then
            REPO_URL="https:\/\/github.com\/mapbox\/mapbox-maps-ios-private.git"
        else
            REPO_URL="https:\/\/github.com\/mapbox\/mapbox-maps-ios.git"
        fi
        sed -i '' -E "s/(pod 'MapboxMaps',).*/\1 :git => '${REPO_URL}', :branch => '${MAPS_VERSION//\//\\/}'/" Podfile
    elif [[ $VERSION_RULE == 1 ]]; then
        sed -i '' -E "s/(pod 'MapboxMaps',).*/\1 '= $MAPS_VERSION'/" Podfile
    fi

    pod install

    info "Building logs available at $ARTIFACTS_ROOT"
    WORKSPACE_PATH="$SCRIPT_DIR/ValidateLatestMaps.xcworkspace"

    results_path="$SCRIPT_DIR/results"
    [[ -d "$results_path" ]] && rm -rf "$results_path"

    for scheme in "${PROJECTS_TO_TEST[@]}"
    do
        step "Building $scheme scheme"
        xcodebuild clean build -workspace "$WORKSPACE_PATH" -scheme "$scheme" -destination 'platform=iOS Simulator,name=iPhone 12' CODE_SIGNING_ALLOWED='NO' &> "$ARTIFACTS_ROOT/${scheme}_xcode-$(date +%Y%m%d%H%M%S).log"
        info "Finished $scheme building"
    done

    git clean -fdx "$SCRIPT_DIR" --quiet
    git checkout HEAD -- Podfile

    exit 0
}

print_usage () {
    cat <<HELP_USAGE
Usage:
        $0 -b branch_name
        $0 -v version_name [-d]

    -v  Force MapboxMaps tag version to be used for SPM build
    -d  Disable downloads validation. Suitable for running validation before binaries would be available
    -o  Enable exclusive validation for direct downloads. It makes sense to run after the first run with -d option
    -b  MapboxMaps branch name to be used
    -p  Use private repo for MapboxMaps
HELP_USAGE
}

while getopts 'b:v:dop' flag; do
case "${flag}" in
    v)  VERSION_RULE=1
        export MAPS_VERSION="$OPTARG"
        export MAPS_VERSION_RULE="version"
        ;;
    b)
        BRANCH_RULE=1
        export MAPS_VERSION="$OPTARG"
        export MAPS_VERSION_RULE="branch"
        ;;
    d)
        ENABLE_DIRECT_DOWNLOADS_VALIDATION=0
        ;;
    o)
        EXCLUSIVE_DIRECT_DOWNLOADS_VALIDATION=1
        ;;
    p)
        PRIVATE_REPO_RULE=1
        ;;
    *) print_usage
    exit 1 ;;
esac
done

if [ $OPTIND -eq 1 ]; then
    print_usage
else
    main
fi

exit 1
