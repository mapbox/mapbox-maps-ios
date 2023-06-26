#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

CLA_SIGNED_GITHUB_EMAIL="it-admin+mapboxci@mapbox.com"

TMP_ROOT=$(mktemp -d)
WORKTREE_TO_REMOVE=""
STAGING_ONLY=false
EXTRA_EMPTY_COMMIT=false

# shellcheck disable=SC2317
cleanup() {
    if [[ -d $WORKTREE_TO_REMOVE ]]
    then
        git -C "$SCRIPT_DIR" worktree remove "$WORKTREE_TO_REMOVE" --force
    fi

    git -C "$SCRIPT_DIR" worktree prune
    rm -rf "$TMP_ROOT"
    exit "$1"
}
trap 'cleanup $?' INT TERM HUP EXIT

# shellcheck source=../utils.sh
source "$UTILS_PATH"

main() {
    # Check that version env exists
    [ -n "$VERSION" ]
    brew_install_if_needed jq
    git_configure_release_user
    git config user.email "$CLA_SIGNED_GITHUB_EMAIL"

    if [ "$STAGING_ONLY" = true ]; then
        step "Update mapbox/maps-ios@publisher-staging"
        maps_ios_upload_docs
        exit 0
    fi

    brew_install_if_needed gh

    step "Update mapbox/ios-sdk"
    ios_sdk_update_versions

    step "Open mapbox/ios-sdk PR"
    ios_sdk_open_pr

    exit 0
}

maps_ios_upload_docs() {
    STAGING_BRANCH_NAME="publisher-staging"
    info "Checkout $STAGING_BRANCH_NAME worktree"
    local staging_docs_path="$TMP_ROOT/docs-staging"
    git worktree add "$staging_docs_path" "$STAGING_BRANCH_NAME" --quiet
    WORKTREE_TO_REMOVE="$staging_docs_path"

    git -C "$staging_docs_path" reset --hard origin/publisher-production --quiet

    info "Copy docs from $DOCS_PATH"
    cp -r "$DOCS_PATH" "$staging_docs_path/$VERSION"

    pushd "$staging_docs_path"  > /dev/null || exit 1
    git_configure_release_user
    git config user.email "$CLA_SIGNED_GITHUB_EMAIL"

    git remote set-url origin "https://x-access-token:$(mbx-ci github writer public token)@github.com/mapbox/mapbox-maps-ios.git"

    info "Commit"
    git add .
    git commit -m "Add documentation for v$VERSION" --quiet

    info "Push"
    git push --force --verbose

    if [ "$STAGING_ONLY" = true ]; then
        git push --force --verbose
    else
        VERSION_BRANCH_NAME="docs/$VERSION"
        git checkout -b "$VERSION_BRANCH_NAME"
        git push --set-upstream origin "$VERSION_BRANCH_NAME" --force --verbose
    fi

    if [ "$EXTRA_EMPTY_COMMIT" = true ]; then
        info "Add empty commit to trigger CI"
        sleep 10 # Avoid CI sometimes cancelling the "Trigger CI" build
        git commit --allow-empty -m "Trigger CI" --quiet
        git push --force --verbose
    fi

    popd > /dev/null
}

should_update_version() {
    local new=$1
    local current=$2

    if [[ "$new" =~ ^v?[0-9]*\.[0-9]*\.[0-9]*$ ]]; then
        # Check if $VERSION is newer than $current_version
        if [[ $(echo -e "$current\n$new" | sort -rV | head -n1) == "$new" ]]; then
            return 0
        fi
    fi
    return 1
}

ios_sdk_update_versions() {
    IOS_SDK_REPO_PATH="$TMP_ROOT/ios-sdk"

    info "Clone repository"
    [[ -d $IOS_SDK_REPO_PATH ]] && rm -rf "$IOS_SDK_REPO_PATH"
    git clone "https://x-access-token:$(mbx-ci github writer private token)@github.com/mapbox/ios-sdk.git" "$IOS_SDK_REPO_PATH" --branch publisher-production --depth=1 --quiet

    pushd "$IOS_SDK_REPO_PATH" || exit 1

    IOS_SDK_BRANCH_NAME="maps-sdk/ios/${VERSION}"

    git_configure_release_user

    git checkout -b "${IOS_SDK_BRANCH_NAME}" --quiet

    # Apply only for release versions
    local current_version
    current_version=$(jq --raw-output ".VERSION_IOS_MAPS_SDK" src/constants.json)

    if should_update_version "$VERSION" "$current_version"; then
        info "Update release version"
        # shellcheck disable=SC2005 # This solution is intentional to modify json in one line with jq
        echo "$(jq ".VERSION_IOS_MAPS_SDK = \"$VERSION\"" src/constants.json)" > src/constants.json
    fi

    info "Add version to the list"
    # shellcheck disable=SC2005
    echo "$(jq "[\"${VERSION}\"] + ." src/data/ios-maps-sdk-versions.json)" > src/data/ios-maps-sdk-versions.json

    info "Commit"
    git add src/constants.json src/data/ios-maps-sdk-versions.json
    git commit -m "Add Maps SDK for iOS ${VERSION} release" --quiet

    info "Push"
    git push --set-upstream origin "${IOS_SDK_BRANCH_NAME}" --force
}

ios_sdk_open_pr() {
    local body="* Release ${VERSION} documentation — Maps SDK for iOS
    Staging URL: https://docs.tilestream.net/ios/maps/api/$VERSION/index.html"
    GITHUB_TOKEN_WRITER=$(mbx-ci github writer private token)

    PR_URL=$(GITHUB_TOKEN=$GITHUB_TOKEN_WRITER \
        gh pr create \
            --repo mapbox/ios-sdk \
            --base publisher-production \
            --head "$IOS_SDK_BRANCH_NAME" \
            --title "[maps] Update for v$VERSION" \
            --label "Maps SDK" \
            --label "update" \
            --body "$body")
    GITHUB_TOKEN="$GITHUB_TOKEN_WRITER" gh pr merge --auto --squash "$PR_URL"

    repeat_command_until_it_fails "approve_pr" 15 20

    info "New PR: $PR_URL"
    pwd
    popd
    echo "$PR_URL" > "ios-sdk-pr.txt"
}

# shellcheck disable=SC2317
approve_pr() {
    GITHUB_TOKEN=$(mbx-ci github writer private token) gh pr review "$PR_URL" --approve
}

print_usage () {
    cat <<HELP_USAGE
Usage:
        $0 -p docs_path

    -p  Path to the generated docs to upload
    -s  To upload docs to staging only
    -e  Push an extra empty commit to trigger CI
HELP_USAGE
}

while getopts 'p:se' flag; do
case "${flag}" in
    p)  DOCS_PATH="$OPTARG"
        if [[ ! -d $DOCS_PATH ]]; then
            exit 1
        fi
        ;;
    s)  STAGING_ONLY=true
        ;;
    e)  EXTRA_EMPTY_COMMIT=true
        ;;
    *) print_usage ;;
esac
done

set -x
main
