#!/usr/bin/env bash
set -eou pipefail

print_usage() {
    cat <<HELP_USAGE
Usage:
        $0 branch_name
HELP_USAGE
}

if [ $# != 1 ]; then
    print_usage
    exit 0
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"
TMP_ROOT=$(mktemp -d)

# shellcheck source=../utils.sh
source "$UTILS_PATH"

BRANCH_NAME=$1

STUDIO_PREVIEW_DIR="$TMP_ROOT/studio-preview-ios"
step "Clone Studio Preview"
git clone "https://x-access-token:$(mbx-ci github reader token)@github.com/mapbox/studio-preview-ios.git" \
 "$STUDIO_PREVIEW_DIR" --depth=1 --quiet
pushd "$STUDIO_PREVIEW_DIR" > /dev/null

step "Install dependencies"
sed -i ''  -E "s/(pod 'MapboxMaps',).*/\1 :git => 'https:\/\/github.com\/mapbox\/mapbox-maps-ios.git', :branch => '${BRANCH_NAME//\//\\/}'/" Podfile
bundle install
bundle exec pod install --repo-update

step "Build Studio Preview"
xcodebuild clean build -workspace StudioPreview.xcworkspace \
           -scheme "StudioPreview" \
           -destination "generic/platform=iOS" \
           CODE_SIGNING_ALLOWED="NO"

finish "Studio Preview builds successfully"
