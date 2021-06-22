#!/bin/bash

# Usage: ./generate-debuggable-environment.sh <mapbox-maps-ios-treeish> <gl-native-internal-treeish> <sdk>

MAPS_SDK_TREEISH="${1:-main}"
GL_NATIVE_TREEISH="${2:-maps-v10.0.0-rc.2}"
SDK="${3:-iphonesimulator}"

echo "$MAPS_SDK_TREEISH"
echo "$GL_NATIVE_TREEISH"
echo "$SDK"

cd mapbox-maps-ios
git fetch --all
git checkout "$MAPS_SDK_TREEISH"
cd ..

cd mapbox-gl-native-internal
git fetch --all
git checkout "$GL_NATIVE_TREEISH"
git submodule sync --recursive
git submodule update --init --recursive
cd ..

# Create xcodeproj for gl-native-internal
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
cd ..

rm MapboxCommon.framework
rm MapboxCoreMaps.framework
ln -s ./DerivedData/Umbrella/Build/Products/Debug-iphonesimulator/MapboxCoreMaps.framework .
ln -s ./mapbox-gl-native-internal/build/ios/lib/Debug/MapboxCommon.framework .

# Turf

git clone https://github.com/mapbox/turf-swift.git
git -C turf-swift checkout 2.0.0-beta.1
xcodebuild archive \
  -project "turf-swift/Turf.xcodeproj" \
  -scheme "Turf iOS" \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -archivePath 'turf-swift/iOS-Simulator.xcarchive' \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO \
  ARCHS='x86_64 arm64' \
  ONLY_ACTIVE_ARCH=YES \
  EXCLUDED_ARCHS= \
  MACH_O_TYPE=mh_dylib \
  LLVM_LTO=NO
SIMULATOR_FRAMEWORK_PATH=$(find turf-swift/iOS-Simulator.xcarchive -name "Turf.framework")
ln -s "$SIMULATOR_FRAMEWORK_PATH" ./

# run xcodegen (project.yml file would specify core and common dependencies (and turf, mme))

xcodegen

# Open the resulting project

xed Umbrella.xcworkspace
