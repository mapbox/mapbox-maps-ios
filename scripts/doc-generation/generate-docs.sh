#!/usr/bin/env bash

# PURPOSE ---------------------------------------------------------------------
# The goal of this script is to generate Jazzy documentation.
# After this script has run, a new folder created in this directory will
# contain the HTML output of the Jazzy doc generation process.
#
# Only call this script if you want to generate documentation manually.
# Otherwise, this script is expected to be called from an automated CI process.
#
# Usage:
#       ./generate-docs.sh GIT_TAG
#
# Parameters:
# - GIT_TAG  - The optional tag to generate docs for.
#              If no value is specified, it uses the current commit
#
# Results:
#       A set of HTML files located in /api-docs containing the
#       API reference for the specified or latest git tag.      
# -----------------------------------------------------------------------------

# SCRIPT SETUP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# -e : Stop executing after the first error in the script
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

SCRIPT_DIR=`dirname "$0"`

# Search for Jazzy and install documentation dependencies if necessary.
if [ -z `which jazzy` ]; then
    $SCRIPT_DIR/install-documentation-dependencies.sh
fi

# The git tag used to generate docs. If one is not provided, HEAD is used.

GIT_TAG=${1:-}
GIT_RECENT_TAG=`git describe --tags --abbrev=0`
GIT_RECENT_TAG_SHA=`git rev-parse $GIT_RECENT_TAG^{}`
GIT_HEAD_SHA=`git rev-parse HEAD`

if [ -n "$GIT_TAG" ]; then 
    # Tag specified
    GIT_REV=$GIT_TAG
else
    # Use current commit...
    GIT_REV=$GIT_HEAD_SHA

    # ...but still may be a tag
    if [ "$GIT_REV" = "$GIT_RECENT_TAG_SHA" ]; then
        GIT_REV=$GIT_RECENT_TAG
    fi
fi

# Check if a directory exists for this tag
DIRECTORY=$SCRIPT_DIR/../../api-docs/$GIT_REV
if [ "$(ls -A $DIRECTORY)" ]; then
     warning "Directory for $GIT_REV already exists, will override"
fi

# Create a directory for the documentation, 
# overriding any existing directory.
mkdir -p $DIRECTORY

# Generate the docs
step "Generating API documentation for $GIT_REV..."

if [ -n "$GIT_TAG"]; then 
    git checkout $GIT_TAG
fi

cd $SCRIPT_DIR/../.. &&
jazzy \
    --author Mapbox \
    --module-version $GIT_REV \
    --module MapboxMaps \
    --title "Mapbox Maps SDK for iOS" \
    --swift-build-tool xcodebuild \
    --build-tool-arguments -scheme,MapboxMaps \
    --sdk iphonesimulator \
    --theme jazzy-theme \
    --output api-docs/$GIT_REV

# Switch back to previous branch
if [ -n "$GIT_TAG"]; then 
    git checkout -
fi

finish "Successfully generated docs for $GIT_REV"
