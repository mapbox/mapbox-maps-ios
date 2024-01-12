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
ENABLE_DIRECT_DOWNLOADS_VALIDATION=1
EXCLUSIVE_DIRECT_DOWNLOADS_VALIDATION=0
SNAPSHOT=0

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

    if [[ $VERSION_RULE == 1 && $SNAPSHOT == 1 ]]; then
        step "Download MapboxMaps binaries - snapshots"

        PROJECTS_TO_TEST=("DirectDynamicDownload" "SwiftPackageManagerIntegration")

        DYNAMIC_ARTIFACTS_DOWNLOAD_PATH="$TMP_ROOT/Dynamic/"
        curl -n "https://api.mapbox.com/downloads/v2/mobile-maps-ios-preview/snapshots/ios/$MAPS_VERSION/MapboxMaps.zip" -o "$TMP_ROOT/MapboxMaps.zip"
        unzip -q "$TMP_ROOT/MapboxMaps.zip" -d "$DYNAMIC_ARTIFACTS_DOWNLOAD_PATH"

        export DYNAMIC_ARTIFACTS_PATH="$DYNAMIC_ARTIFACTS_DOWNLOAD_PATH/artifacts"
    fi

    set +u
    if [[ -n "$CIRCLE_REPOSITORY_URL" ]]; then
        REPOSITORY_NAME=${CIRCLE_REPOSITORY_URL##*/}
    else
        REPOSITORY_NAME="mapbox-maps-ios.git"
    fi
    set -u

    step "Generate Xcode project with Xcodegen"
    pushd "$SCRIPT_DIR" > /dev/null || exit 1
    MBX_TOKEN="$(cat ~/.mapbox)" REPOSITORY_NAME="${REPOSITORY_NAME}" xcodegen

    if [[ $SNAPSHOT == 0 ]]; then
        if [[ $BRANCH_RULE == 1 ]]; then
            sed -i '' -E "s/(pod 'MapboxMaps',).*/\1 :path => '..\/..'/" Podfile
        elif [[ $VERSION_RULE == 1 ]]; then
            sed -i '' -E "s/(pod 'MapboxMaps',).*/\1 '= $MAPS_VERSION'/" Podfile
        fi

        pod install
    fi

    info "Building logs available at $ARTIFACTS_ROOT"

    results_path="$SCRIPT_DIR/results"
    [[ -d "$results_path" ]] && rm -rf "$results_path"

    for scheme in "${PROJECTS_TO_TEST[@]}"
    do
        step "Building $scheme scheme"
        set +e
        LOG_FILE="$ARTIFACTS_ROOT/${scheme}_xcode-$(date +%Y%m%d%H%M%S).log"

        if ! xcodebuild clean build COMPILER_INDEX_STORE_ENABLE=NO \
            ${XCODE_BUILD_SETTING:--workspace "$SCRIPT_DIR/ValidateLatestMaps.xcworkspace"} \
            -scheme "$scheme" -destination 'generic/platform=iOS Simulator' \
            CODE_SIGNING_ALLOWED='NO' &> "$LOG_FILE"; then
            cat "$LOG_FILE"
            exit 1
        fi

        set -e
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
    -s  Use snapshot version
HELP_USAGE
}

while getopts 'b:v:dops' flag; do
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
    s)
        SNAPSHOT=1
        export XCODE_BUILD_SETTING="-project "$SCRIPT_DIR/ValidateLatestMaps.xcodeproj""
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
