#!/bin/bash

echo "Inserting Mapbox access token..."
token_file=~/.mapbox
token_file2=~/mapbox
token="$(cat $token_file 2>/dev/null || cat $token_file2 2>/dev/null)"

if [ "$token" ]; then
    echo "#define MAPBOX_ACCESS_TOKEN $token" > $INFOPLIST_PREFIX_HEADER
    echo "Generated $INFOPLIST_PREFIX_HEADER"
else
    echo \'error: Missing Mapbox access token\'
    echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at ~/.mapbox that contains the access token."
    exit 1
fi
