#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd "$SCRIPT_DIR/../" || exit

VERSIONS_PATH="scripts/release/packager/versions.json"
MAPBOX_CORE_MAPS_VERSION="$(jq -r .MapboxCoreMaps $VERSIONS_PATH)"
MAPBOX_COMMON_VERSION="$(jq -r .MapboxCommon $VERSIONS_PATH)"
MAPBOX_TURF_VERSION="$(jq -r .Turf $VERSIONS_PATH)"

XCODE_VERSION="$(xcodebuild -version | head -1 | cut -d ' ' -f 2)"

release_folder() {
    [[ $1 = *"SNAPSHOT"* ]] && echo "snapshots" || echo "releases"
}

cat <<EOF > Cartfile.MapboxCoreMaps.json
{"$MAPBOX_CORE_MAPS_VERSION": "https://api.mapbox.com/downloads/v2/mobile-maps-core/$(release_folder "$MAPBOX_CORE_MAPS_VERSION")/ios/packages/$MAPBOX_CORE_MAPS_VERSION/MapboxCoreMaps.xcframework-dynamic.zip"}
EOF

cat <<EOF > Cartfile.MapboxCommon.json
{"$MAPBOX_COMMON_VERSION": "https://api.mapbox.com/downloads/v2/mapbox-common/$(release_folder "$MAPBOX_COMMON_VERSION")/ios/packages/$MAPBOX_COMMON_VERSION/MapboxCommon.zip"}
EOF

cat <<EOF > Cartfile
# xcode version: $XCODE_VERSION
binary "Cartfile.MapboxCoreMaps.json" == $MAPBOX_CORE_MAPS_VERSION
binary "Cartfile.MapboxCommon.json" == $MAPBOX_COMMON_VERSION
github "mapbox/turf-swift" == $MAPBOX_TURF_VERSION

EOF

cat <<EOF > Cartfile.xcconfig
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
EOF

mkdir -p Carthage
CURRENT_CONFIG_HASH=$(cat Cartfile Cartfile.xcconfig Cartfile.MapboxCoreMaps.json Cartfile.MapboxCommon.json | shasum -a 256)

EXPECTED_CONFIG_HASH=""
if [[ -f Carthage/config.version ]]; then
    EXPECTED_CONFIG_HASH=$(cat Carthage/config.version)
fi

if [[ "$CURRENT_CONFIG_HASH" != "$EXPECTED_CONFIG_HASH" ]]; then
    if [[ $(command -v "carthage") ]]; then
        CARTHAGE_BINARY="carthage"
    elif [[ $(command -v "mint") ]]; then
        CARTHAGE_BINARY="mint run Carthage/Carthage"
    else
        echo "error: Carthage not found"
        exit 1
    fi

    # build xcframeworks for visionOS starting from xcode 15.2
    PLATFORM="iOS"
    if [[ "$(printf '%s\n' "$XCODE_VERSION" "15.2" | sort -V -r | head -n1)" == "$XCODE_VERSION" ]]; then
        PLATFORM="iOS,visionOS"
    fi

    $CARTHAGE_BINARY update --use-netrc --platform $PLATFORM --verbose --use-xcframeworks --cache-builds --configuration Cartfile.xcconfig

    echo "$CURRENT_CONFIG_HASH" > Carthage/config.version
fi

rm -f Cartfile Cartfile.resolved Cartfile.xcconfig Cartfile.MapboxCoreMaps.json Cartfile.MapboxCommon.json
