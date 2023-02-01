#!/usr/bin/env sh

# Support Howebrew path on Apple Silicon macOS
export PATH="$PATH:/opt/homebrew/bin"

cd ../../
pwd

if which swiftlint > /dev/null; then
  swiftlint lint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

