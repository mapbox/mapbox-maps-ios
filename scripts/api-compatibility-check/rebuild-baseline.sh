#!/usr/bin/env bash

set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"


API_DIGESTER_PATH="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-api-digester"

# Folder to unzip products
PRODUCTS_DIR="$SCRIPT_DIR"
PRODUCT_ARTIFACTS_DIR="$PRODUCTS_DIR/artifacts"

if [[ -d "$PRODUCT_ARTIFACTS_DIR" ]]; then
    rm -rf "$PRODUCT_ARTIFACTS_DIR"
fi

LATEST_PUBLIC_VERSION=$(gh release view --json name -q ".name")
step "Download ${LATEST_PUBLIC_VERSION} binaries"

curl -n "https://api.mapbox.com/downloads/v2/mobile-maps-ios/releases/ios/${LATEST_PUBLIC_VERSION#v}/MapboxMaps.zip" --output "$SCRIPT_DIR/MapboxMaps.zip"

unzip -q "$SCRIPT_DIR/MapboxMaps.zip" -d "$PRODUCTS_DIR"
rm -rf "$SCRIPT_DIR/MapboxMaps.zip"

#  Workaround for swift-api-digester – move all swiftmodules and modulemaps to the framework roots
#       to avoid 'module was built in directory '.framework' but now resides in directory '/Modules' error
iOS_FRAMEWORK_PATHS=$(find "$PRODUCT_ARTIFACTS_DIR" -path '*.framework' ! -path "*simulator*" ! -path "*maccatalyst*")

for frameworkPath in $iOS_FRAMEWORK_PATHS; do
    modulePath="$frameworkPath/Modules"

    mv "$modulePath"/* "$frameworkPath"
done

# 4. Build new baseline digester dump
BASELINE_REPORT_DIR="$SCRIPT_DIR/API"
BASELINE_REPORT_PATH="$BASELINE_REPORT_DIR/iphoneos.json"
BASELINE_OLD_REPORT_PATH="$BASELINE_REPORT_DIR/iphoneos_old.json"
BASELINE_ARCHIVE_PATH="$SCRIPT_DIR/.baseline.zip"

# mkdir "$BASELINE_REPORT_DIR"
unzip -q "$BASELINE_ARCHIVE_PATH" -d "$SCRIPT_DIR"
# Move actual report to the old location to compare reports.
mv "$BASELINE_REPORT_PATH" "$BASELINE_OLD_REPORT_PATH"

step "Generate new JSON API dump"
xcrun --sdk iphoneos "$API_DIGESTER_PATH"\
    --dump-sdk \
    --module=MapboxMaps\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/MapboxCommon.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/MapboxCoreMaps.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMobileEvents.xcframework/ios-arm64/MapboxMobileEvents.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/Turf.xcframework/ios-arm64/Turf.framework/\
    -target arm64-apple-ios11.0\
    --iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/ \
    --iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/ \
    --abort-on-module-fail\
    --avoid-tool-args --avoid-location\
    --output-dir "$SCRIPT_DIR" \
     -v
# 5. Pack generated baseline report to compare with
cd "$SCRIPT_DIR" || exit 1

set +e
if ! cmp -s <(jq -S . "$BASELINE_OLD_REPORT_PATH") <(jq -S . "$BASELINE_REPORT_PATH") > /dev/null; then
    info "JSON API dump has changed. Updating the baseline"
    rm -f "$BASELINE_ARCHIVE_PATH"
    rm -f "$BASELINE_OLD_REPORT_PATH"
    zip -r "$BASELINE_ARCHIVE_PATH" "API"
fi
set -e

rm -rf "$BASELINE_REPORT_DIR"

rm -rf "$PRODUCT_ARTIFACTS_DIR"

finish "Rebuilding baseline finished successfully"