#!/usr/bin/env bash

# Usage: Used as a build phase script in Xcode to run SwiftLint
# Dependencies: MAPBOXMAPS_PATH (relative path to mapbox-maps-ios) build setting must be set in target that use this script, in order to find the .swiftlint.yml file

# Support Howebrew path on Apple Silicon macOS
export PATH="$PATH:/opt/homebrew/bin"

echo "MAPBOXMAPS_PATH=$MAPBOXMAPS_PATH"

pushd "$MAPBOXMAPS_PATH" || exit 1
pwd

echo "Running SwiftLint in $PWD"

if which swiftlint > /dev/null; then
  swiftlint lint "$@"
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
