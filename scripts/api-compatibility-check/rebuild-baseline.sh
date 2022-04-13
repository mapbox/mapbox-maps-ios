#!/usr/bin/env bash

set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BASEAPI_REF=$(cat "$SCRIPT_DIR/.baseapi")
BASEAPI_WORKTREE_PATH="$SCRIPT_DIR/.$BASEAPI_REF.checkout"
BASEAPI_PACKAGER_DIR="$BASEAPI_WORKTREE_PATH/scripts/release/packager"

API_DIGESTER_PATH="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-api-digester"

# Folder to unzip products
PRODUCTS_DIR="$SCRIPT_DIR"
PRODUCT_ARTIFACTS_DIR="$PRODUCTS_DIR/artifacts"

# 1. Checkout tag
git worktree add "$BASEAPI_WORKTREE_PATH" "$BASEAPI_REF"
pushd "$BASEAPI_PACKAGER_DIR" || exit 1

# 2. Build release products as for distribution (with enabled library evolution and so on)
./package-mapbox-maps.sh
unzip "$BASEAPI_PACKAGER_DIR/MapboxMaps.zip" -d "$PRODUCTS_DIR"
git worktree remove "$BASEAPI_WORKTREE_PATH" --force

# 3. Workaround for swift-api-digester – move all swiftmodules and modulemaps to the framework roots
#       to avoid 'module was built in directory '.framework' but now resides in directory '/Modules' error
iOS_FRAMEWORK_PATHS=$(find "$PRODUCT_ARTIFACTS_DIR" -path '*.framework' ! -path "*simulator*" ! -path "*maccatalyst*")

for frameworkPath in $iOS_FRAMEWORK_PATHS; do
    modulePath="$frameworkPath/Modules"

    mv "$modulePath"/* "$frameworkPath"
done

# 4. Build new baseline digester dump
BASELINE_REPORT_DIR="$SCRIPT_DIR/API"
BASELINE_ARCHIVE_PATH="$SCRIPT_DIR/.baseline.zip"

rm -f "$BASELINE_ARCHIVE_PATH"
mkdir "$BASELINE_REPORT_DIR"

xcrun --sdk iphoneos "$API_DIGESTER_PATH"\
    -dump-sdk \
    -module MapboxMaps\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMaps.xcframework/ios-arm64/MapboxMaps.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/MapboxCommon.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/MapboxCoreMaps.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/MapboxMobileEvents.xcframework/ios-arm64/MapboxMobileEvents.framework/\
    -I "$PRODUCT_ARTIFACTS_DIR"/Turf.xcframework/ios-arm64/Turf.framework/\
    -target arm64-apple-ios11.0\
    -iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCommon.xcframework/ios-arm64_armv7/ \
    -iframework "$PRODUCT_ARTIFACTS_DIR"/MapboxCoreMaps.xcframework/ios-arm64/ \
    -abort-on-module-fail\
    -avoid-tool-args -avoid-location\
    -output-dir "$SCRIPT_DIR" \
     -v
# 5. Pack generated baseline report to compare with
cd "$SCRIPT_DIR" || exit 1
zip -r "$BASELINE_ARCHIVE_PATH" "API"
rm -rf "$BASELINE_REPORT_DIR"

rm -rf "$PRODUCT_ARTIFACTS_DIR"
