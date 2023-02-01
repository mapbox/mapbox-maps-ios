#!/usr/bin/env bash

#
# Usage:
#   ./scripts/release/update-version.sh <maps sem version number>
#

set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
SEM_VERSION=${SEM_VERSION/#v}
SHORT_VERSION=${SEM_VERSION%%-*}

brew_install_if_needed jq

step "Version ${SEM_VERSION}"

# Update Info.plist
step "Update Info.plist"
plutil -replace CFBundleShortVersionString -string "$SHORT_VERSION" Sources/MapboxMaps/Info.plist
plutil -convert json -o - Sources/MapboxMaps/Info.plist | jq -r '.CFBundleVersion = ((.CFBundleVersion|tonumber + 1)|tostring)' | plutil -convert xml1 -o Sources/MapboxMaps/Info.plist -

# Update MapboxMaps.podspec
step "Update Podspec"
sed -i '' s/"maps_version = '.*'"/"maps_version = '${SEM_VERSION}'"/ MapboxMaps.podspec

# Update MapboxMaps.json
step "Update MapboxMaps.json"
sed -i '' s/"\"version\" : \".*\""/"\"version\" : \"${SEM_VERSION}\""/ Sources/MapboxMaps/MapboxMaps.json

finish "Completed updating versions"
