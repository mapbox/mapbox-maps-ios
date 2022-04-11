#!/usr/bin/env bash

set -eo pipefail
print_usage() {
        cat <<HELP_USAGE
Usage:
        $0 [-p MapboxMaps.zip]
    -p  Path to pre-packaged MapboxMaps
HELP_USAGE
}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PACKAGER_DIR="$SCRIPT_DIR/../release/packager"

API_DIGESTER_PATH="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-api-digester"

ARTIFACTS_ZIP_PATH=""

main() {
    local products_dir="$SCRIPT_DIR"
    local product_artifacts_dir="$products_dir/artifacts"

    rm -rf "$SCRIPT_DIR/API"
    rm -rf "$product_artifacts_dir"

    if [[ ! -f "$ARTIFACTS_ZIP_PATH" ]]; then
        cd "$PACKAGER_DIR" || exit 1
        ./package-mapbox-maps.sh

        ARTIFACTS_ZIP_PATH="$PACKAGER_DIR/MapboxMaps.zip"
    fi

    unzip "$ARTIFACTS_ZIP_PATH" -d "$products_dir" >/dev/null

    iOS_FRAMEWORK_PATHS=$(find "$product_artifacts_dir" -path '*.framework' ! -path "*simulator*" ! -path "*maccatalyst*")

    for frameworkPath in $iOS_FRAMEWORK_PATHS; do
        modulePath="$frameworkPath/Modules"

        mv "$modulePath"/* "$frameworkPath"
    done


    unzip "$SCRIPT_DIR/.baseline.zip" -d "$SCRIPT_DIR" >/dev/null

    report="$SCRIPT_DIR/MapboxMaps.report"

    xcrun --sdk iphoneos "$API_DIGESTER_PATH" \
        --diagnose-sdk\
        --abort-on-module-fail\
        -I "$product_artifacts_dir"/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/\
        -I "$product_artifacts_dir"/MapboxCommon.xcframework/ios-arm64_armv7/MapboxCommon.framework/\
        -I "$product_artifacts_dir"/MapboxCoreMaps.xcframework/ios-arm64/MapboxCoreMaps.framework/\
        -I "$product_artifacts_dir"/MapboxMobileEvents.xcframework/ios-arm64/MapboxMobileEvents.framework/\
        -I "$product_artifacts_dir"/Turf.xcframework/ios-arm64/Turf.framework/\
        -target arm64-apple-ios11.0\
        --iframework "$product_artifacts_dir"/MapboxCommon.xcframework/ios-arm64_armv7/ \
        --iframework "$product_artifacts_dir"/MapboxCoreMaps.xcframework/ios-arm64/ \
        --breakage-allowlist-path "$SCRIPT_DIR/breakage_allowlist.txt" \
        --baseline-dir "$SCRIPT_DIR"\
        -module MapboxMaps \
        2>&1 > "$report" 2>&1

    # the shasum here is for an empty report, i.e. no changes
    # if the shasum of the new report is different, then there's
    # obviously an API change
    if ! shasum "$report" | grep -q afd2a1b542b33273920d65821deddc653063c700; then
        echo ERROR
        echo >&2 "======================================"
        echo >&2 "ERROR: public API change in MapboxMaps"
        echo >&2 "======================================"
        cat >&2 "$report"
        exit 1
    else
        echo OK
    fi
}


while getopts 'p:' flag; do
case "${flag}" in
    p) ARTIFACTS_ZIP_PATH="$OPTARG" ;;
    *) print_usage
    exit 1 ;;
esac
done

main
