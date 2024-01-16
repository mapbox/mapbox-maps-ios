#!/bin/bash

# Usage: Used as a build phase script to inject the Mapbox access to a file in the test bundle.
# Dependencies: MAPBOXMAPS_PATH (relative path to mapbox-maps-ios) build setting must be set in target that use this script, in order to create the MapboxAccessToken file.

echo "Generating Mapbox Access Token File..."
token_file=~/.mapbox
token_file2=~/mapbox
token="$(cat $token_file 2>/dev/null || cat $token_file2 2>/dev/null)"

if [ "$token" ]; then
    echo "${token}" > "$MAPBOXMAPS_PATH/Tests/MapboxMapsTests/Helpers/MapboxAccessToken"
    echo "Generated $INFOPLIST_PREFIX_HEADER"
else
    echo \'error: Missing Mapbox access token\'
    echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at ~/.mapbox that contains the access token."
    exit 1
fi
