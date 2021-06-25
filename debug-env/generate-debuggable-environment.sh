#!/bin/bash

# Usage: ./generate-debuggable-environment.sh <mapbox-maps-ios-commit> <gl-native-internal-commit> <turf-commit> <mme-commit>

if [ -d build ] ; then
  echo "build directory exists; please delete or move the directory before running this script"
  exit 1
fi

MAPS_SDK_COMMIT="${1:-main}"
GL_NATIVE_COMMIT="${2:-internal}"
TURF_COMMIT="${3:-main}"
MME_COMMIT="${4:-main}"

echo "Using:"
echo " - mapbox-maps-ios @ $MAPS_SDK_COMMIT"
echo " - mapbox-gl-native-internal @ $GL_NATIVE_COMMIT"
echo " - turf-swift @ $TURF_COMMIT"
echo " - mapbox-events-ios @ $MME_COMMIT"

get_branch () {
  git clone "git@github.com:mapbox/$1.git"
  git -C "$1" checkout "$2"
}

# Create a separate directory for intermediates
mkdir -p build
cd build

# Core & Common
get_branch mapbox-gl-native-internal "$GL_NATIVE_COMMIT"
git -C mapbox-gl-native-internal submodule sync --recursive
git -C mapbox-gl-native-internal submodule update --init --recursive
cd mapbox-gl-native-internal
cmake -B build/ios \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="./lib"\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_SYSROOT=iphoneos \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DMAPBOX_COMMON_BUILD_TYPE='SHARED' \
  -DMAPBOX_COMMON_TARGET_NAME='MapboxCommon' \
  -DMAPBOX_COMMON_ADD_LIBOUTDIR_TO_FRAMEWORK_SEARCH_PATH=ON \
  -DMAPBOX_ENABLE_FRAMEWORK=ON \
  -DMBGL_WITH_IOS_CCACHE=ON \
  -DMBGL_WITH_METAL=ON \
  -GXcode
## xcodegen chokes on the PBXBuildStyle objects in the generated project file.
## They're a legacy construct, and everything works if you just delete them.
sed -i '' '/Begin PBXBuildStyle section/,/End PBXBuildStyle section/d' 'build/ios/Mapbox GL Native.xcodeproj/project.pbxproj'
cd ..

# Turf, MME, MapboxMaps
get_branch turf-swift "$TURF_COMMIT"
get_branch mapbox-events-ios "$MME_COMMIT"
get_branch mapbox-maps-ios "$MAPS_SDK_COMMIT"

# leave build directory
cd ..

# Generate Xcode projects
xcodegen -s MapboxMaps.yml
xcodegen -s DebugApp.yml
xcodegen -s Examples.yml

# Open the resulting project
xed Umbrella.xcworkspace
