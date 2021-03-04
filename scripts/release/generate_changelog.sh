#!/usr/bin/env bash

set -euo pipefail

#
# Usage:
#   ./scripts/release/generate_changelog.sh <Base branch> <Compare tag>
#
# Result:
#   A generated CHANGELOG that will prepend to the existing file
#   A commit and push to the current branch you are on to add the updated CHANGELOG file

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }

# Branch that is passed as input
BASE_BRANCH=${1}
COMPARE_TAG=${2}

# Guarantees installation of release tools
npm install -g @mapbox/github-release-tools

# Generate a changelog draft comparing the main branch, to the last release ($TAG)
step "Generating changelog comparing $BASE_BRANCH to $COMPARE_TAG"
changelog-draft -b $BASE_BRANCH -p $COMPARE_TAG -o CHANGELOG.md
finish "Changelog generated. See CHANGELOG.md for updates"

finish "See commit for branch \"$BRANCH\" to see diff in github UI"