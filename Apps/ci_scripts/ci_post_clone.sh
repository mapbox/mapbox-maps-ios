#!/bin/sh

echo "machine api.mapbox.com login mapbox password $SDK_REGISTRY_TOKEN" >> ~/.netrc
chmod 0600 ~/.netrc

pwd
echo "$SDK_REGISTRY_TOKEN" > "../Tests/MapboxMapsTests/Helpers/MapboxAccessToken"
