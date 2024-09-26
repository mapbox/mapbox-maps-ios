#!/usr/bin/env bash
set -eou pipefail

# Function to display usage information
usage() {
    echo "Usage: $0 --mode <validate|generate> -v <versions_json_path> -m <mapboxmaps_json_path> -o <license_output_path>"
    exit 1
}

# Initialize default variables
MODE="generate"
DEFAULT_VERSIONS_JSON_PATH="scripts/release/packager/versions.json"
DEFAULT_MAPBOXMAPS_JSON_PATH="Sources/MapboxMaps/MapboxMaps.json"
DEFAULT_LICENSE_OUTPUT_PATH="LICENSE.md"

# Parse command-line arguments
while getopts "v:m:o:-:" opt; do
    case $opt in
        -)
            case "${OPTARG}" in
                mode)
                    val="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
                    MODE=$val
                    ;;
                *)
                    usage
                    ;;
            esac
            ;;
        v) VERSIONS_JSON_PATH=$OPTARG ;;
        m) MAPBOXMAPS_JSON_PATH=$OPTARG ;;
        o) LICENSE_OUTPUT_PATH=$OPTARG ;;
        *) usage ;;
    esac
done

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "This script requires GITHUB_TOKEN variable to be set."
    exit 1
fi

VERSIONS_JSON_PATH=${VERSIONS_JSON_PATH:-$DEFAULT_VERSIONS_JSON_PATH}
MAPBOXMAPS_JSON_PATH=${MAPBOXMAPS_JSON_PATH:-$DEFAULT_MAPBOXMAPS_JSON_PATH}
LICENSE_OUTPUT_PATH=${LICENSE_OUTPUT_PATH:-$DEFAULT_LICENSE_OUTPUT_PATH}

# Extract versions from the provided JSON paths
COREMAPS_VERSION=$(jq -r .MapboxCoreMaps "$VERSIONS_JSON_PATH")

if [[ $COREMAPS_VERSION = *"SNAPSHOT"* ]]; then
    # Skipping license check for GL Native snapshots.
    exit 0
fi

TURF_VERSION=$(jq -r .Turf "$VERSIONS_JSON_PATH")
MAPS_SDK_VERSION=$(jq -r .version "$MAPBOXMAPS_JSON_PATH")
CURRENT_YEAR=$(date +%Y)

# Fetch license contents from GitHub
TURF_LICENSE_CONTENT=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/turf-swift/contents/LICENSE.md?ref=v$TURF_VERSION" --jq ".content" | base64 --decode)
CORE_LICENSE=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/mapbox-sdk/contents/projects/gl-native/LICENSE-iOS.md?ref=gl-native/v$COREMAPS_VERSION" --jq ".content" | base64 --decode)

# Fetch versions.json from the monorepo
MONOREPO_VERSIONS_JSON=$(gh api -H "Accept: application/vnd.github+json" "/repos/mapbox/mapbox-sdk/contents/versions.json?ref=gl-native/v$COREMAPS_VERSION" --jq ".content" | base64 --decode)
MONOREPO_CORE_LOCAL_VERSION="$(echo "$MONOREPO_VERSIONS_JSON" | jq -r '.projects | .["gl-native"] | .local')"
MONOREPO_CORE_HEAD_VERSION=$(echo "$MONOREPO_VERSIONS_JSON" | jq -r '.projects | .["gl-native"] | .head')

# Monorepo don't store release version in license files. Instead, version is updated in CI runtime before distribution.
# Replacing 'local' version with 'head' version to avoid license validation issues.
CORE_LICENSE="${CORE_LICENSE/$MONOREPO_CORE_LOCAL_VERSION/$MONOREPO_CORE_HEAD_VERSION}"


LICENSE_TEMPLATE="changequote("""","""")dnl # prevents m4 from being confused with backquotes by changing quotes to non-existent tokens
## License

Mapbox Maps for iOS version __MAPS_SDK_VERSION__
Mapbox Maps iOS SDK

Copyright &copy; 2021 - __YEAR__ Mapbox, Inc. All rights reserved.

The software and files in this repository (collectively, “Software”) are licensed under the Mapbox TOS for use only with the relevant Mapbox product(s) listed at www.mapbox.com/pricing. This license allows developers with a current active Mapbox account to use and modify the authorized portions of the Software as needed for use only with the relevant Mapbox product(s) through their Mapbox account in accordance with the Mapbox TOS.  This license terminates automatically if a developer no longer has a Mapbox account in good standing or breaches the Mapbox TOS. For the license terms, please see the Mapbox TOS at https://www.mapbox.com/legal/tos/ which incorporates the Mapbox Product Terms at www.mapbox.com/legal/service-terms.  If this Software is a SDK, modifications that change or interfere with marked portions of the code related to billing, accounting, or data collection are not authorized and the SDK sends limited de-identified location and usage data which is used in accordance with the Mapbox TOS. [Updated 2023-01]

## Acknowledgements

This application makes use of the following third party libraries:

### turf-swift, https://github.com/mapbox/turf-swift

\`\`\`
__TURF_LICENSE_CONTENT__
\`\`\`

---

__CORE_LICENSE__
"

EXPECTED_LICENSE=$(echo "$LICENSE_TEMPLATE" | m4 -D __MAPS_SDK_VERSION__="$MAPS_SDK_VERSION" \
                                                -D __TURF_LICENSE_CONTENT__="$TURF_LICENSE_CONTENT" \
                                                -D __CORE_LICENSE__="$CORE_LICENSE" \
                                                -D __YEAR__="$CURRENT_YEAR")

if [ "$MODE" == "validate" ]; then
    if [[ "$(cat "$LICENSE_OUTPUT_PATH")" == "$EXPECTED_LICENSE" ]]; then
        echo "License file is up-to-date."
        exit 0
    else
        echo "⚠️ License is not up-to-date. ⚠️"
        exit 1
    fi
elif [ "$MODE" == "generate" ]; then
    echo "$EXPECTED_LICENSE" > "$LICENSE_OUTPUT_PATH"
    echo "License file has been updated."
else
    usage
fi
