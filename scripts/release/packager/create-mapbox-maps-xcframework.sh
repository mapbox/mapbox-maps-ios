#!/bin/bash

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

# Simulator
step "Archiving iPhone simulator framework"
xcodebuild  -archivePath 'pkg/MapboxMaps-simulator.xcarchive' \
		    -project 'MapboxMapsPackager.xcodeproj' \
		    -scheme MapboxMaps \
		    -sdk iphonesimulator \
		    -configuration Release \
		    -derivedDataPath .derivedDataPath-simulator \
			archive \
			ARCH=x86_64 \
			ONLY_ACTIVE_ARCH=YES \
			BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
			SKIP_INSTALL=NO \
			SUPPORTS_MACCATALYST=YES

SIMULATOR_FRAMEWORK_PATH=$(find pkg/MapboxMaps-simulator.xcarchive -name MapboxMaps.framework)

# Device
step "Archiving iPhone device framework"
xcodebuild  -archivePath 'pkg/MapboxMaps-device.xcarchive' \
		    -project 'MapboxMapsPackager.xcodeproj' \
		    -scheme MapboxMaps \
		    -sdk iphoneos \
		    -configuration Release \
		    -derivedDataPath .derivedDataPath-device \
			archive \
			ARCH='armv7 arm64' \
			ONLY_ACTIVE_ARCH=YES \
			BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
			SKIP_INSTALL=NO \
			SUPPORTS_MACCATALYST=YES

DEVICE_FRAMEWORK_PATH=$(find pkg/MapboxMaps-device.xcarchive -name MapboxMaps.framework)

# Create xcframework
step "Creating xcframework"
xcodebuild -create-xcframework \
		   -framework ${SIMULATOR_FRAMEWORK_PATH} \
		   -framework ${DEVICE_FRAMEWORK_PATH} \
		   -output MapboxMaps.xcframework

# Cleaning up
step "Cleaning up artifacts"
rm -rf .derivedDataPath-*
rm -rf pkg
