#!/bin/bash

echo "Inserting Mapbox access token..."
token_file=~/.mapbox
token_file2=~/mapbox
token="$(cat $token_file 2>/dev/null || cat $token_file2 2>/dev/null)"
plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
if [ "$token" ]; then
  plutil -replace MBXAccessToken -string "$token" "$plist"
  echo "Token insertion successful"
elif plutil -extract MBXAccessToken xml1 "$plist" -o - | grep "<string></string>"; then
  echo \'error: Missing Mapbox access token\'
  echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at ~/.mapbox that contains the access token."
  exit 1
fi
