#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/create-api-downloads-pr.sh <project root> <version number without v prefix>
#

PROJECT_ROOT=$1
VERSION=$2

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

# Variables needed for github actions
BRANCH_NAME="$PROJECT_ROOT/$VERSION"
TMPDIR=$(mktemp -d)

git clone "https://x-access-token:$(mbx-ci github writer private token)@github.com/mapbox/api-downloads.git" "$TMPDIR"
pushd "$TMPDIR" || exit 1
echo "Checking out to $TMPDIR"
git checkout -b "$BRANCH_NAME"

#
# Add config file for dynamic
#
generate_config() {
  local project=$1
  local version=$2
  local suffix=$3

  if [ -d "$HOME" ]; then
    cat <<- EOF > "config/$project$suffix/$version.yaml"
		api-downloads: v2

		bundles:
		  ios: MapboxMaps$suffix
		EOF
  fi
}

generate_config "$PROJECT_ROOT" "$VERSION" ""
generate_config "$PROJECT_ROOT" "$VERSION" "-static"

#
# Commit to branch
#

git config --global user.email "maps_sdk_ios@mapbox.com"
git config --global user.name "Release SDK bot for Maps SDK team"

git add -A
git commit -m "[maps-ios] Add config for $PROJECT_ROOT @ $VERSION"
git push --set-upstream origin "$BRANCH_NAME"

#
# Create PR
#

body="Bump maps version to ${VERSION}"
GITHUB_TOKEN_WRITER=$(mbx-ci github writer private token)

PR_URL=$(GITHUB_TOKEN=$GITHUB_TOKEN_WRITER \
    gh pr create \
        --repo mapbox/api-downloads \
        --base main \
        --head "$BRANCH_NAME" \
        --title "[maps, ios] Update config for $PROJECT_ROOT @ $VERSION" \
        --body "$body")
GITHUB_TOKEN="$GITHUB_TOKEN_WRITER" gh pr merge --auto --squash "$PR_URL"
approve_pr() {
  GITHUB_TOKEN=$(mbx-ci github writer private token) gh pr review "$PR_URL" --approve
}

echo "New PR: $PR_URL"
repeat_command_until_it_fails "approve_pr" 15 20

pwd
popd
echo "$PR_URL" > "api-downloads-pr.txt"
