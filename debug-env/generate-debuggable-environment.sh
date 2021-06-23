#!/bin/bash

# Usage: ./generate-debuggable-environment.sh <mapbox-maps-ios-treeish> <gl-native-internal-treeish> <turf-treeish> <mme-treeish> <sdk>

MAPS_SDK_TREEISH="${1:-main}"
GL_NATIVE_TREEISH="${2:-maps-v10.0.0-rc.2}"
TURF_TREEISH="${3:-v2.0.0-beta.1}"
MME_TREEISH="${4:-v1.0.2}"
SDK="${5:-iphonesimulator}"

echo "$MAPS_SDK_TREEISH"
echo "$GL_NATIVE_TREEISH"
echo "$TURF_TREEISH"
echo "$MME_TREEISH"
echo "$SDK"

# Create a separate directory for intermediates

mkdir -p build
cd build

# Core & Common

git -C mapbox-gl-native-internal fetch --all 2> /dev/null || git clone git@github.com:mapbox/mapbox-gl-native-internal.git
git -C mapbox-gl-native-internal checkout "$GL_NATIVE_TREEISH"
git -C mapbox-gl-native-internal submodule sync --recursive
git -C mapbox-gl-native-internal submodule update --init --recursive

## Create xcodeproj

cd mapbox-gl-native-internal
cmake -B build/ios \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="./lib"\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_SYSROOT="$SDK" \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DMAPBOX_COMMON_BUILD_TYPE='SHARED' \
  -DMAPBOX_COMMON_TARGET_NAME='MapboxCommon' \
  -DMAPBOX_COMMON_ADD_LIBOUTDIR_TO_FRAMEWORK_SEARCH_PATH=ON \
  -DMAPBOX_ENABLE_FRAMEWORK=ON \
  -DMBGL_WITH_IOS_CCACHE=ON \
  -DMBGL_WITH_METAL=ON \
  -GXcode

# xcodegen chokes on the PBXBuildStyle objects in the generated project file. They're a legacy (Xcode 3.2) construct, and everything works if you just delete them.
sed -i '' '/Begin PBXBuildStyle section/,/End PBXBuildStyle section/d' 'build/ios/Mapbox GL Native.xcodeproj/project.pbxproj'

cd ..

# Turf

git -C turf-swift fetch --all 2> /dev/null || git clone git@github.com:mapbox/turf-swift.git
git -C turf-swift checkout "$TURF_TREEISH"

# Mobile Events

git -C mapbox-events-ios fetch --all 2> /dev/null || git clone git@github.com:mapbox/mapbox-events-ios.git
git -C mapbox-events-ios checkout "$MME_TREEISH"

# MapboxMaps

git -C mapbox-maps-ios fetch --all 2> /dev/null || git clone git@github.com:mapbox/mapbox-maps-ios.git
git -C mapbox-maps-ios checkout "$MAPS_SDK_TREEISH"

# leave build directory
cd ..

# Generate Xcode project

xcodegen

# Open the resulting project

xed Umbrella.xcworkspace
