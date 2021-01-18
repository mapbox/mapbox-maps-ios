#!/usr/bin/env bash


# PURPOSE ---------------------------------------------------------------------
# The goal of this script is to install the necessary dependencies
# required to generate API documentation. This script is optionally run
# as part of generate-docs.sh, in the event that the machine running it
# has not installed the required dependencies.
# -----------------------------------------------------------------------------

# SCRIPT SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# -e : Stop executing after the first error in the script
# -u : Print message to stderr when it tries to expand a 
#      variable that is not set.
# -o pipefail: Fail piped commands on the first failure.
set -e -u -o pipefail

# Log a step with cyan text color
function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
# Log an informational warning with yellow text color
function warning { >&2 echo -e "\033[1m\033[33m! $@\033[0m"; }
# Log an error with red text color
function error { >&2 echo -e "\033[1m\033[31mⅹ $@\033[0m"; }
# Log the completion with green text color
function finish { >&2 echo -e "\033[1m\033[32m✔ $@\033[0m"; }
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# VARIABLES
COCOAPODS_VERSION="1.7.5"
JAZZY_VERSION="0.13.6"
CIRCLECI=${CIRCLECI:-false}

## Install CocoaPods
if [[ -z `which pod` || $(pod --version) != "${COCOAPODS_VERSION}" ]]; then
    step "Installing CocoaPods"

    if [[ "${CIRCLECI}" == true ]]; then
        sudo gem install cocoapods -v $COCOAPODS_VERSION --no-document
    else
        gem install cocoapods -v $COCOAPODS_VERSION --no-document
    fi

    if [ -z `which pod` ]; then
        error "Unable to install cocoapods ($COCOAPODS_VERSION)."
        exit 1
    fi
else
    echo "Found CocoaPods (${COCOAPODS_VERSION})"
fi

## Install Jazzy
if [[ -z `which jazzy` || $(jazzy -v) != "jazzy version: ${JAZZY_VERSION}" ]]; then
    step "Installing Jazzy…"

    if [[ "${CIRCLECI}" == true ]]; then
        sudo gem install jazzy -v $JAZZY_VERSION --no-document
    else
        gem install jazzy -v $JAZZY_VERSION --no-document
    fi

    if [ -z `which jazzy` ]; then
        error "Unable to install Jazzy ($JAZZY_VERSION). See https://github.com/mapbox/mapbox-gl-native-ios/blob/main/platform/ios/INSTALL.md"
        exit 1
    fi
else
    step "Found Jazzy (${JAZZY_VERSION})"
fi

finish "Finished installing documentation dependencies"