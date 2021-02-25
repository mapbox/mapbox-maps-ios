#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/generate_changelog.sh <Branch to compare with last tag>
#
# Result:
#   A generated CHANGELOG that will prepend to the existing file
#   A commit and push to the current branch you are on to add the updated CHANGELOG file

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }

# Branch that is passed as input
BRANCH=${1}

# Guarantees installation of release tools
npm install -g @mapbox/github-release-tools

# Base branch to compare to and where we want to commit our changes
git checkout ${BRANCH}

# Remove any existing local tags if there are any, and then fetch all remote tags
git tag -d $(git tag -l)
git fetch --tags

# Get all tags matching '10.0.0*' in order of latest activity
# TODO: Modularize this so that it is not hardcoded to version 10.0.0
ORDERED_TAGS=`git tag -l --sort=-committerdate -l "v10.0.*"`

# Gets the tag in array index 1 because a new tag was just pushed which represents array at position 0, the last release will be at position 1
LAST_RELEASE="$(cut -d' ' -f1 <<<$ORDERED_TAGS)"

# Generate a changelog draft comparing the main branch, to the last release ($TAG)
step "Generating changelog comparing $BRANCH to $LAST_RELEASE"
changelog-draft -b $BRANCH -p $LAST_RELEASE -o CHANGELOG.md
finish "Changelog generated. See CHANGELOG.md for updates"

git add CHANGELOG.md
git commit -m "Updated changelog since $LAST_RELEASE"
git push --set-upstream origin $BRANCH

finish "See commit for branch \"$BRANCH\" to see diff in github UI"