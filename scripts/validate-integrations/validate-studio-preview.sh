#!/usr/bin/env bash
set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"
TMP_ROOT=$(mktemp -d)

# shellcheck source=../utils.sh
source "$UTILS_PATH"

DEPENDENCY_RULE="branch"
BRANCH_OR_COMMIT_NAME=

STUDIO_PREVIEW_DIR="$TMP_ROOT/studio-preview-ios"
ARTIFACTS_ROOT=${DEFAULT_ARTIFACTS_DIR:-$TMP_ROOT}

main() {
    step "Clone Studio Preview"
    git clone "https://x-access-token:$(mbx-ci github reader token)@github.com/mapbox/studio-preview-ios.git" \
    "$STUDIO_PREVIEW_DIR" --depth=1 --quiet
    pushd "$STUDIO_PREVIEW_DIR" > /dev/null

    step "Install dependencies"
    sed -i ''  -E "s/(pod 'MapboxMaps',).*/\1 :git => 'https:\/\/github.com\/mapbox\/mapbox-maps-ios.git', :${DEPENDENCY_RULE} => '${BRANCH_OR_COMMIT_NAME//\//\\/}'/" Podfile
    cat Podfile
    bundle install
    bundle exec pod install --repo-update

    step "Build Studio Preview"
    xcodebuild clean build -workspace StudioPreview.xcworkspace \
            -scheme "StudioPreview" \
            -destination "generic/platform=iOS" \
            CODE_SIGNING_ALLOWED="NO"  &> "$ARTIFACTS_ROOT/validate-studio-preview_xcode.log"

    finish "Studio Preview builds successfully"
}

print_usage () {
    cat <<HELP_USAGE
Usage:
        $0 -b branch_name
        $0 -c commit

    -b  MapboxMaps branch name to be used in Studio Preview Podfile with :branch => rule
    -c  MapboxMaps commit hash to be used in Studio Preview Podfile with :commit => rule
HELP_USAGE
}

while getopts 'b:c:' flag; do
case "${flag}" in
    c)  DEPENDENCY_RULE="commit"
        export BRANCH_OR_COMMIT_NAME="$OPTARG"
        ;;
    b)
        DEPENDENCY_RULE="branch"
        export BRANCH_OR_COMMIT_NAME="$OPTARG"
        ;;

    *) print_usage

    exit 1 ;;
esac
done

if [ $OPTIND -eq 1 ]; then
    print_usage
else
    main
fi

exit 1
