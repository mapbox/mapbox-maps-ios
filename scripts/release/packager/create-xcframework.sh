#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

PROJECT=${1}
SCHEME=${2}
PRODUCT=${3}

# Create iOS Simulator Framework
step 'Archiving iOS Simulator Framework'
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath '.create-xcframework/iOS-Simulator.xcarchive' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  ARCHS='x86_64 arm64' \
  EXCLUDED_ARCHS=

SIMULATOR_FRAMEWORK_PATH=$(find .create-xcframework/iOS-Simulator.xcarchive -name "$PRODUCT.framework")

# Create iOS Device Framework
step 'Archiving iOS Device Framework'
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath '.create-xcframework/iOS.xcarchive' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  ARCHS='arm64' \
  EXCLUDED_ARCHS=

DEVICE_FRAMEWORK_PATH=$(find .create-xcframework/iOS.xcarchive -name "$PRODUCT.framework")

# Create XCFramework
step 'Creating XCFramework'
xcodebuild \
  -create-xcframework \
  -framework "$SIMULATOR_FRAMEWORK_PATH" \
  -framework "$DEVICE_FRAMEWORK_PATH" \
  -output "$PRODUCT.xcframework"

# Clean Up
step 'Cleaning up artifacts'
rm -rf .create-xcframework
