#!/bin/zsh

echo "machine api.mapbox.com login mapbox password $SDK_REGISTRY_TOKEN" >> ~/.netrc
echo "$SDK_REGISTRY_TOKEN" >> ~/.mapbox
chmod 0600 ~/.netrc

pwd
echo "$SDK_REGISTRY_TOKEN" > "$CI_WORKSPACE/Tests/MapboxMapsTests/Helpers/MapboxAccessToken"
