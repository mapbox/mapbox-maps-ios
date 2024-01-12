#!/usr/bin/env bash
set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
public_repo_root="$script_dir/../../"

# Usage: build-docc.sh <hosting_base_path> <output_path>

hosting_base_path=${1:-"/ios/maps/api/latest/"}
docc_archive=${2:-"$(pwd)/MapboxMaps.doccarchive"}
theme_dir="$script_dir/docc-theme"
docc_sources_path="$public_repo_root/Sources/MapboxMaps/Documentation.docc"


cleanup() {
    rm -fr "$docc_sources_path/"*.html
}

process_template() {
    cp -f "$theme_dir/$1" "$docc_sources_path/$1"
    sed -i "" "s|BASE_PATH|$hosting_base_path|g" "$docc_sources_path/$1"
}

build_doc() {
    pushd "$public_repo_root/"
    xcodebuild docbuild -config Release -scheme MapboxMaps -destination "generic/platform=iOS" \
        COMPILER_INDEX_STORE_ENABLE=NO OTHER_DOCC_FLAGS="--warnings-as-errors --experimental-enable-custom-templates --output-path $docc_archive --hosting-base-path $hosting_base_path"
    popd
}

patch_docc_theme() {
    index_css=$(find "$docc_archive/css" -name 'index.*.css')
    cat "$theme_dir/docc-inject.css" >> "$index_css"

    cp "$theme_dir/assembly.min.css"  "$docc_archive/css/"
    cp "$theme_dir/page-shell-styles.css"  "$docc_archive/css/"
}

update_favicon() {
    cp "$theme_dir/favicon.ico" "$docc_archive/"
    cp "$theme_dir/favicon.svg" "$docc_archive/"
}

rm -fr "$docc_archive"
trap cleanup EXIT ERR
process_template footer.html
process_template header.html
build_doc
patch_docc_theme
update_favicon
echo Created "$docc_archive"
