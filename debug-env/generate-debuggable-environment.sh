#!/bin/bash

# Usage: ./generate-debuggable-environment.sh <mapbox-maps-ios-treeish> <gl-native-internal-treeish> <turf-treeish> <mme-treeish>

MAPS_SDK_TREEISH="${1:-main}"
GL_NATIVE_TREEISH="${2:-internal}"
TURF_TREEISH="${3:-main}"
MME_TREEISH="${4:-main}"
SDK="${5:-iphoneos}"

echo "Using:"
echo " - mapbox-maps-ios @ $MAPS_SDK_TREEISH"
echo " - mapbox-gl-native-internal @ $GL_NATIVE_TREEISH"
echo " - turf-swift @ $TURF_TREEISH"
echo " - mapbox-events-ios @ $MME_TREEISH"
echo "Configuring for $SDK SDK"

get_branch () {
  git -C "$1" fetch "$2":"$2" 2> /dev/null || git clone "git@github.com:mapbox/$1.git"
  git -C "$1" checkout "$2"
}

# Create a separate directory for intermediates
mkdir -p build
cd build

# Core & Common
get_branch mapbox-gl-native-internal "$GL_NATIVE_TREEISH"
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
get_branch turf-swift "$TURF_TREEISH"
get_branch mapbox-events-ios "$MME_TREEISH"
get_branch mapbox-maps-ios "$MAPS_SDK_TREEISH"

# leave build directory
cd ..

# Generate Xcode projects
xcodegen -s MapboxMaps.yml
xcodegen -s DebugApp.yml
xcodegen -s Examples.yml

# Open the resulting project
xed Umbrella.xcworkspace
