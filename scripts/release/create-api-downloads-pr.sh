#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-api-downloads-pr.sh <project root> <version number without v prefix>
#

PROJECT_ROOT=$1
VERSION=$2

# Variables needed for github actions
BRANCH_NAME="${PROJECT_ROOT}/${VERSION}"
GITHUB_TOKEN=$(./scripts/release/get_token.js)

TMPDIR=`mktemp -d`

git clone https://x-access-token:$GITHUB_TOKEN@github.com/mapbox/api-downloads.git ${TMPDIR}
cd ${TMPDIR}
echo "Checking out to ${TMPDIR}"
git checkout -b ${BRANCH_NAME}

#
# Add config file
#

cat << EOF > config/${PROJECT_ROOT}/${VERSION}.yaml
api-downloads: v2

packages:
  ios:
      - MapboxMaps.xcframework

bundles:
  ios: mapbox-maps-ios
EOF

#
# Commit to branch
#
git add -A
git commit -m "[maps-ios] Add config for ${PROJECT_ROOT} @ ${VERSION}"
git push --set-upstream origin ${BRANCH_NAME}

#
# Create PR
# Requires that GITHUB_TOKEN environment variable is set, which is done on line 17
#

git config --global user.email "maps_sdk_ios@mapbox.com"
git config --global user.name "Release SDK bot for Maps SDK team"

TITLE="Update config for ${PROJECT_ROOT} @ ${VERSION}"
URL="https://api.github.com/repos/mapbox/api-downloads/pulls"
BODY="{\"head\":\"${BRANCH_NAME}\",\"base\":\"main\",\"title\":\"${TITLE}\",\"body\":\"${REFERENCE}\"}"

CURL_RESULT=0
HTTP_CODE=$(curl ${URL} \
    --write-out %{http_code} \
    --silent \
    --output /dev/null \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "${BODY}" -w "%{response_code}") || CURL_RESULT=$?

cd -
rm -rf ${TMPDIR}

if [[ ${CURL_RESULT} != 0 ]]; then
    echo "Failed to create PR (curl error: ${CURL_RESULT})"
    exit $CURL_RESULT
fi
if [[ ${HTTP_CODE} != "201" ]]; then
    echo "Failed to create PR (http code: ${HTTP_CODE})"
    exit 1
fi
