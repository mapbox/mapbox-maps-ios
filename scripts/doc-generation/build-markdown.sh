#!/usr/bin/env bash
set -euo pipefail

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
public_repo_root="$script_dir/../../"

# Usage: build-markdown.sh <hosting_base_path> <output_path> <use_project>
# Builds markdown pages into a docc archive, reusing the symbol graphs from build-docc.sh.
# The pages are in <output_path>/data/documentation, next to the page data.

hosting_base_path=${1:-"/ios/maps/api/latest/"}
markdown_archive=${2:-"$(pwd)/MapboxMaps.markdown.doccarchive"}
use_project=${3:-"MapboxMaps.xcodeproj"}

# Markdown output in Xcode's docc lacks member lists (swiftlang/swift-docc#1625).
# TODO: Once Xcode's docc has it, drop this script and pass
# --enable-experimental-markdown-output in build-docc.sh instead.
swift_docc_repo="https://github.com/swiftlang/swift-docc.git"
swift_docc_rev="swift-DEVELOPMENT-SNAPSHOT-2026-09-21-a"
swift_docc_dir="${SWIFT_DOCC_CACHE_DIR:-$HOME/.cache/swift-docc}/$swift_docc_rev"
docc="$swift_docc_dir/.build/release/docc"

build_docc_tool() {
    if [[ -x "$docc" ]]; then return; fi
    rm -fr "$swift_docc_dir"
    git init -q "$swift_docc_dir"
    git -C "$swift_docc_dir" fetch -q --depth 1 "$swift_docc_repo" "$swift_docc_rev"
    git -C "$swift_docc_dir" checkout -q FETCH_HEAD
    swift build --package-path "$swift_docc_dir" -c release --product docc
}

build_markdown() {
    pushd "$public_repo_root/"
    products_dir=$(xcodebuild -project "$use_project" -showBuildSettings -config Release -scheme MapboxMaps -destination "generic/platform=iOS" 2>/dev/null \
        | awk -F' = ' '$1 ~ / BUILT_PRODUCTS_DIR$/ {print $2}')
    if [[ ! -d "$products_dir/symbol-graphs" ]]; then
        echo "No symbol graphs in '$products_dir', run build-docc.sh first" >&2
        exit 1
    fi

    "$docc" convert Sources/MapboxMaps/Documentation.docc \
        --fallback-display-name MapboxMaps \
        --fallback-bundle-identifier com.mapbox.MapboxMaps \
        --fallback-bundle-version 1 \
        --diagnostic-level error \
        --additional-symbol-graph-dir "$products_dir/symbol-graphs" \
        --hosting-base-path "$hosting_base_path" \
        --enable-experimental-markdown-output \
        --no-transform-for-static-hosting \
        --output-dir "$markdown_archive"
    popd
}

rm -fr "$markdown_archive"
build_docc_tool
build_markdown
"$script_dir/patch-markdown-links.py" "$markdown_archive/data" "$hosting_base_path"
echo "Created $markdown_archive with $(find "$markdown_archive/data/documentation" -name '*.md' | wc -l | tr -d ' ') markdown pages"
