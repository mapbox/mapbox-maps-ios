#!/usr/bin/env bash

#
# This file should be copied to .git/hooks/pre-commit by running `scripts/install-pre-commit/install-pre-commit.sh`
#

if [ -z `which secret-shield` ]; then
    echo 'Please install secret-shield globally. https://github.com/mapbox/secret-shield'; exit;
fi

secret-shield --pre-commit -C verydeep --enable "Mapbox Public Key" --disable "High-entropy base64 string" "Short high-entropy string" "Long high-entropy string"
