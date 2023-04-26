#!/usr/bin/env bash

# Support Howebrew path on Apple Silicon macOS
export PATH="$PATH:/opt/homebrew/bin"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

pushd "$SCRIPT_DIR/../" || exit 1
pwd

# shellcheck disable=SC2068
if which swiftlint > /dev/null; then
  swiftlint lint $@
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
