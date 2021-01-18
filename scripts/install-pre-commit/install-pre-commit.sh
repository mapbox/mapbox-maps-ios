#!/usr/bin/env bash

#
# This installs a pre-commit that runs secret-shield.
#

cp scripts/install-pre-commit/pre-commit.sh ././.git/hooks/pre-commit
chmod +x ././.git/hooks/pre-commit