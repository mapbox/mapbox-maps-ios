#!/usr/bin/env bash

pod_inject_cdn_version() {
    local library_name=$1
    local version=$2

    pod repo add-cdn trunk https://cdn.cocoapods.org/
    pod search "$library_name" --no-pager > /dev/null
    LIBRARY_NAME_HASH=$(md5 -qs "$library_name")
    CDN_HASH_PATH="$HOME/.cocoapods/repos/trunk/all_pods_versions_${LIBRARY_NAME_HASH:0:1}_${LIBRARY_NAME_HASH:1:1}_${LIBRARY_NAME_HASH:2:1}.txt"
    cat "$CDN_HASH_PATH"
    sed -i '' -E "s/($library_name.*)/\1\/${version}/g" "$CDN_HASH_PATH"
    cat "$CDN_HASH_PATH"
}
