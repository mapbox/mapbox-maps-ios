#!/usr/bin/env bash
#
# Usage:
#   ./scripts/ci/ci-e2e-job-trigger-checker.sh
#
# This script will query information about the current PR when used in CircleCI environment.
# The information is used to decide whether the end-to-end compatibility testing pipeline needs to be launched.
#

if [ "$CIRCLE_TAG" != "" ]; then
    echo "We are on tag $CIRCLE_TAG, trigger all the bots."
    exit 0
fi

export GITHUB_TOKEN=$(mbx-ci github reader token)

IS_BRANCH_PROTECTED=$(gh api repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/branches/$CIRCLE_BRANCH --jq .protected)
if [ $IS_BRANCH_PROTECTED != "false" ]; then
    echo "We are on protected branch, trigger all the bots."
    exit 0
fi

if [ -z "$CIRCLE_PULL_REQUEST" ]; then
    echo "No pull request created yet. Please create pull request in order to finish CI."
    exit 1
fi

echo "Checking PR $CIRCLE_PULL_REQUEST"

COMMIT_MESSAGE=$(gh api repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/commits/$CIRCLE_SHA1 --jq .commit.message)
#echo $COMMIT_MESSAGE

if [ -z "${COMMIT_MESSAGE##*"run_e2e"*}"  ]; then
    echo "Trigger downstream E2E bots due to run_e2e request in commit."
    exit 0
fi

LABELS=$(gh pr view --repo $CIRCLE_REPOSITORY_URL $CIRCLE_PULL_REQUEST --json labels)
#echo $LABELS

if [[ "$LABELS" == *"run_e2e"* ]]; then
    echo "E2E requested in PR labels."
    exit 0
fi

echo "No need to trigger downstream E2E bots."
exit 1