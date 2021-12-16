#!/usr/bin/env bash


git_recent_vtag() { git describe --tags --abbrev=0 "$(git_recent_vtag_hash)"; }

git_recent_vtag_hash() { git rev-list --tags='v*' --max-count=1 ; }

git_head_hash() { git rev-parse HEAD ; }

git_configure_release_user() {
    git config user.name "Release SDK bot"
    git config user.email "release-bot@mapbox.com"
}
