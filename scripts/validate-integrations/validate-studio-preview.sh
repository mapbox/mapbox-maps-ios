#!/usr/bin/env bash
set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"
TMP_ROOT=$(mktemp -d)

# shellcheck source=../utils.sh
source "$UTILS_PATH"

STUDIO_PREVIEW_DIR="$TMP_ROOT/studio-preview-ios"
ARTIFACTS_ROOT=${DEFAULT_ARTIFACTS_DIR:-$TMP_ROOT}

step "Clone Studio Preview"
git clone "https://x-access-token:$(mbx-ci github reader token)@github.com/mapbox/studio-preview-ios.git" \
"$STUDIO_PREVIEW_DIR" --depth=1 --quiet
pushd "$STUDIO_PREVIEW_DIR" > /dev/null

step "Install dependencies"
sed -i ''  -E "s/(pod 'MapboxMaps',).*/\1 :path => '~\/project\/mapbox-maps-ios'/" Podfile
cat Podfile
bundle install
bundle exec pod install --repo-update

step "Build Studio Preview"
xcodebuild clean build -workspace StudioPreview.xcworkspace \
        -scheme "StudioPreview" \
        -destination "generic/platform=iOS" \
        CODE_SIGNING_ALLOWED="NO"  &> "$ARTIFACTS_ROOT/validate-studio-preview_xcode-$(date +%Y%m%d%H%M%S).log"

finish "Studio Preview builds successfully"
exit 0
