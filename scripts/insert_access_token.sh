#!/bin/bash

echo "Inserting Mapbox access token..."
token_file=~/.mapbox
token_file2=~/mapbox
token="$(cat $token_file 2>/dev/null || cat $token_file2 2>/dev/null)"
plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"

# Only overwrite or error if the Info.plist contains the MBXAccessToken key with an empty value
# This allows overriding ~/.mapbox and ~/mapbox by editing the Info.plist directly and avoids
# emitting an error if the Info.plist is not configured to need an access token.
if existing_value="$(/usr/libexec/PlistBuddy -c "Print :MBXAccessToken" "$plist")" && [ -z "$existing_value" ]; then
  if [ "$token" ]; then
    plutil -replace MBXAccessToken -string "$token" "$plist"
    echo "Token insertion successful"
  else
    echo \'error: Missing Mapbox access token\'
    echo "error: Get an access token from <https://www.mapbox.com/studio/account/tokens/>, then create a new file at ~/.mapbox that contains the access token."
    exit 1
  fi
fi
