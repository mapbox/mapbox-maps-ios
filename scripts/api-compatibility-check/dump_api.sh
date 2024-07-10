#!/usr/bin/env bash
set -x
set -euo pipefail

# Define the parameters
OUTPUT=${1}
BASELINE=${2}
MAPBOX_MAPS_DIR=${3}
PACKAGE_MAPBOX_SCRIPT=${4}
BREAKING_API_CHECK_SCRIPT=${5}
MAPBOX_MAPS_VERSION_FILE=${6}
BINARY_OUTPUT=${7}

# Check if the output file exists and the baseline flag is true
if [[ -f "$OUTPUT" && "$BASELINE" == "true" ]]; then
  echo "File $OUTPUT exists."
  exit 0
fi

# Checkout the specific version if baseline is true
if [ "$BASELINE" == "true" ]; then
  git checkout "$(cat "$MAPBOX_MAPS_VERSION_FILE")"
fi

PACKAGER_DIR="$MAPBOX_MAPS_DIR/scripts/release/packager"
"$PACKAGE_MAPBOX_SCRIPT" dynamic "$PACKAGER_DIR/versions.json" "$PACKAGER_DIR/create-xcframework.sh" "$PACKAGER_DIR/project.yml" "$MAPBOX_MAPS_DIR" "$MAPBOX_MAPS_DIR/LICENSE.md"
mv MapboxMaps*.zip "$MAPBOX_MAPS_DIR"

# Checkout back to the original branch if baseline is true
if [ "$BASELINE" == "true" ]; then
  git checkout -
fi

# Run the API compatibility check script
"$BREAKING_API_CHECK_SCRIPT" dump "$MAPBOX_MAPS_DIR/MapboxMaps.zip" --module MapboxMaps -o "$OUTPUT"
mv "$MAPBOX_MAPS_DIR/MapboxMaps.zip" "$BINARY_OUTPUT"