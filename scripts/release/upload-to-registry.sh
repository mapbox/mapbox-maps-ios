#!/usr/bin/env bash
# Usage: ./upload-to-registry.sh </path/to/source/zip> <project> <version> <zipfile name>

# Direct Download //s3://mapbox-api-downloads-production/v2/mobile-maps-ios/releases/ios/<version>/mapbox-maps-ios.zip
# SPM/Pods //s3://mapbox-api-downloads-production/v2/mobile-maps-ios/releases/ios/<version>/packages/MapboxMaps.xcframework.zip

set -euo pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

if [[ ! ${#} -eq 4 ]]; then
    echo "Usage: ./upload-to-registry.sh </path/to/source/zip> <project> <version> <zipfile name>"
    exit 1
fi

if [[ "${AWS_ACCESS_KEY_ID:-invalid}" == "invalid" ]]; then
    echo AWS_ACCESS_KEY_ID not set.
    exit 1
fi

if [[ "${AWS_SECRET_ACCESS_KEY:-invalid}" == "invalid" ]]; then
    echo AWS_SECRET_ACCESS_KEY not set.
    exit 1
fi

SOURCE_ZIP=$1
PROJECT=$2
VERSION=$3
ZIP_FILENAME=$4

S3_DESTINATION=s3://mapbox-api-downloads-production/v2/${PROJECT}/releases/ios/${VERSION}/${ZIP_FILENAME}
DOWNLOAD_URL=https://api.mapbox.com/downloads/v2/${PROJECT}/releases/ios/${VERSION}/${ZIP_FILENAME}

step "Uploading ${SOURCE_ZIP} to ${S3_DESTINATION}"
aws s3 cp ${SOURCE_ZIP} ${S3_DESTINATION} ${S3_ARGS:-}
step "Download URL will be ${DOWNLOAD_URL}"
