#!/usr/bin/env bash

#
# Usage:
#   ./scripts/release/update-version.sh <maps sem version number>
#

set -e
set -o pipefail
set -u

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
SEM_VERSION=${SEM_VERSION/#v}
SHORT_VERSION=${SEM_VERSION%-*}

step "Version ${SEM_VERSION}"

# Update Info.plist
step "Update Info.plist"
plutil -replace CFBundleShortVersionString -string "$SHORT_VERSION" Sources/MapboxMaps/Info.plist
plutil -convert json -o - Sources/MapboxMaps/Info.plist | jq -r '.CFBundleVersion = ((.CFBundleVersion|tonumber + 1)|tostring)' | plutil -convert xml1 -o Sources/MapboxMaps/Info.plist -

# Update MapboxMaps.podspec
step "Update Podspec"
sed -i '' s/"maps_version = '.*'"/"maps_version = '${SEM_VERSION}'"/ MapboxMaps.podspec

finish "Completed updating versions"
