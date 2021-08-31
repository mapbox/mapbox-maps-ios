#!/usr/bin/env bash

set -eo pipefail

#
# Usage:
#   ./scripts/semver-check.sh <current release version (empty for branches)> <previous release version> <api compat string (major|minor|patch)>
#

if [[ $# -ne 3 ]]; then
    echo "Incorrect number of parameters"
    exit 1
fi

TAGGED_RELEASE_VERSION=$1
LAST_VERSION=$2
API_COMPAT_LEVEL=$3

# Checking if tagged release has API breaks
if [[ ! -z ${TAGGED_RELEASE_VERSION} ]] && [[ ! ${TAGGED_RELEASE_VERSION} =~ "rc." ]] && [[ ! ${LAST_VERSION} =~ "rc." ]]; then
    SEMVER_REGEX="(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(\\-[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?(\\+[0-9A-Za-z-]+(\\.[0-9A-Za-z-]+)*)?"
    if [[ ${TAGGED_RELEASE_VERSION} =~ $SEMVER_REGEX ]]; then
        newMajor=${BASH_REMATCH[1]}
        newMinor=${BASH_REMATCH[2]}
        newPatch=${BASH_REMATCH[3]}
    else
        echo "Could not parse new release version (${TAGGED_RELEASE_VERSION})" >&2
        exit 1
    fi

    if [[ ${LAST_VERSION} =~ $SEMVER_REGEX ]]; then
        oldMajor=${BASH_REMATCH[1]}
        oldMinor=${BASH_REMATCH[2]}
        oldPatch=${BASH_REMATCH[3]}
    else
        echo "Could not parse old release version (${LAST_VERSION})" >&2
        exit 1
    fi

    if [[ ${API_COMPAT_LEVEL} == "major" ]] && [[ ${newmajor} != $((oldmajor+1)) ]]; then
        echo "Major API breaking change. Major version number must be incremented."
        exit 1
    elif [[ ${API_COMPAT_LEVEL} == "minor" ]] && [[ ${newMinor} != $((oldMinor+1)) ]]; then
        echo "Minor API breaking change. Minor version number must be incremented."
        exit 1
    elif [[ ${API_COMPAT_LEVEL} == "patch" ]] && [[ ${newPatch} != $((oldPatch+1)) ]]; then
        echo "Patch version number must be incremented."
        exit 1
    else
        echo "Release tagged with correct version."
    fi
else
    echo "Checked API breaks for branch or release candidate."
    if [[ ${API_COMPAT_LEVEL} == "major" ]] || [[ ${API_COMPAT_LEVEL} == "minor" ]];then
        echo "Current version has (${API_COMPAT_LEVEL}) API changes comparing to ${LAST_VERSION}"
    else
        echo "Current version is a (${API_COMPAT_LEVEL}) release for the ${LAST_VERSION}"
    fi
fi
