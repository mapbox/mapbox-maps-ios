#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

CLA_SIGNED_GITHUB_EMAIL="it-admin+mapboxci@mapbox.com"

TMP_ROOT=$(mktemp -d)
WORKTREE_TO_REMOVE=""

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

    brew_install_if_needed gh

    step "Update mapbox/ios-sdk"
    ios_sdk_update_versions

    step "Open mapbox/ios-sdk PR"
    ios_sdk_open_pr

    exit 0
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
    git clone "https://x-access-token:$GITHUB_WRITER_PRIVATE_TOKEN@github.com/mapbox/ios-sdk.git" "$IOS_SDK_REPO_PATH" --branch publisher-production --depth=1 --quiet

    pushd "$IOS_SDK_REPO_PATH" || exit 1

    IOS_SDK_BRANCH_NAME="maps-sdk/ios/${VERSION}"

    # Check if branch already exists remotely
    if git ls-remote --heads origin "$IOS_SDK_BRANCH_NAME" | grep -q "$IOS_SDK_BRANCH_NAME"; then
        info "Branch $IOS_SDK_BRANCH_NAME already exists, skipping creating docs PR."
        cleanup 0
    fi

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
    GITHUB_TOKEN_WRITER=$GITHUB_WRITER_PRIVATE_TOKEN

    PR_URL=$(GITHUB_TOKEN=$GITHUB_WRITER_PRIVATE_TOKEN \
        gh pr create \
            --repo mapbox/ios-sdk \
            --base publisher-production \
            --head "$IOS_SDK_BRANCH_NAME" \
            --title "[maps] Update for v$VERSION" \
            --label "Maps SDK" \
            --label "update" \
            --body "$body")
    GITHUB_TOKEN="$GITHUB_WRITER_PRIVATE_TOKEN" gh pr merge --auto --squash "$PR_URL"

    # repeat_command_until_it_fails "approve_pr" 15 20

    info "New PR: $PR_URL"
    pwd
    popd
    echo "$PR_URL" > "ios-sdk-pr.txt"

    if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
        echo "Docs PR: $PR_URL " >> $GITHUB_STEP_SUMMARY
    fi
}

# shellcheck disable=SC2317
approve_pr() {
    GITHUB_TOKEN=$GITHUB_WRITER_PRIVATE_TOKEN gh pr review "$PR_URL" --approve
}

set -x
main
