#!/usr/bin/env bash
# Usage: ./make-core-maps-framework.sh <path/to/source.xcframework> <path/to/dest.framework>

mkdir -p "$2"
cp -R "$1/ios-arm64/MapboxCoreMaps.framework/Headers" "$2"
cp -R "$1/ios-arm64/MapboxCoreMaps.framework/Modules" "$2"
cp "$1/ios-arm64/MapboxCoreMaps.framework/Info.plist" "$2"

lipo "$1/ios-arm64_x86_64-simulator/MapboxCoreMaps.framework/MapboxCoreMaps" -thin x86_64 -output MapboxCoreMaps_x86_64

lipo -create \
    "$1/ios-arm64/MapboxCoreMaps.framework/MapboxCoreMaps" \
    MapboxCoreMaps_x86_64 \
    -output "$2/MapboxCoreMaps"

rm MapboxCoreMaps_x86_64
