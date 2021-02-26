#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

PRODUCT=${1}
LINK_TYPE=${2}
SCHEME=${3:-"$PRODUCT"}
PROJECT=${4:-"$PRODUCT.xcodeproj"}

if [ "$LINK_TYPE" = "DYNAMIC" ]; then
    MACH_O_TYPE=mh_dylib
elif [ "$LINK_TYPE" = "STATIC" ]; then
    MACH_O_TYPE=staticlib
else
    echo "Error: Invalid link type: $LINK_TYPE"
    echo "Usage: $0 [DYNAMIC|STATIC]"
    exit 1
fi

# Create iOS Simulator Framework
step "Archiving iOS Simulator Framework for $PRODUCT"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath '.create-xcframework/iOS-Simulator.xcarchive' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  ARCHS='x86_64 arm64' \
  EXCLUDED_ARCHS= \
  MACH_O_TYPE="$MACH_O_TYPE" \
  LLVM_LTO=NO

SIMULATOR_FRAMEWORK_PATH=$(find .create-xcframework/iOS-Simulator.xcarchive -name "$PRODUCT.framework")

# Create iOS Device Framework
step "Archiving iOS Device Framework for $PRODUCT"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath '.create-xcframework/iOS.xcarchive' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  ARCHS='arm64' \
  EXCLUDED_ARCHS= \
  MACH_O_TYPE="$MACH_O_TYPE" \
  LLVM_LTO=NO

DEVICE_FRAMEWORK_PATH=$(find .create-xcframework/iOS.xcarchive -name "$PRODUCT.framework")

# Create XCFramework
step "Creating $PRODUCT.xcframework"
xcodebuild \
  -create-xcframework \
  -framework "$SIMULATOR_FRAMEWORK_PATH" \
  -framework "$DEVICE_FRAMEWORK_PATH" \
  -output "$PRODUCT.xcframework"

# Clean Up
step "Cleaning up intermediate artifacts for $PRODUCT"
rm -rf .create-xcframework
