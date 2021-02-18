#!/bin/bash

# Usage: ./generate-debuggable-environment.sh

# Create xcodeproj for gl-native-internal
cd mapbox-gl-native-internal
mkdir -p build/ios 
cd build/ios
cmake ../.. -DBUILD_SHARED_LIBS=OFF \
            -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY="./lib"\
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_OSX_SYSROOT=iphonesimulator \
            -DCMAKE_SYSTEM_NAME=iOS \
            -DMAPBOX_COMMON_BUILD_TYPE='SHARED' \
            -DMAPBOX_COMMON_TARGET_NAME='MapboxCommon' \
            -DMAPBOX_ENABLE_FRAMEWORK=ON \
            -DMBGL_WITH_IOS_CCACHE=ON \
            -DMBGL_WITH_METAL=ON \
            -GXcode
cd ../../../

# Make the deps in carbon
cd mapbox-maps-ios
make deps

# Manipulating symlinks
cd lib
rm MapboxCommon.framework
rm MapboxCoreMaps.framework
ln -s ./../../DerivedData/Umbrella/Build/Products/Debug-iphonesimulator/MapboxCoreMaps.framework .
ln -s ./../../mapbox-gl-native-internal/build/ios/lib/Debug/MapboxCommon.framework .
cd ..

# Open the workspace
cd ..
xed Umbrella.xcworkspace