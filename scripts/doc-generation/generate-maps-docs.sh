#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
UTILS_PATH="$SCRIPT_DIR/../utils.sh"

# shellcheck source=../utils.sh
source "$UTILS_PATH"

VERSION=${VERSION:-$(git_head_hash)}
DOCS_OUTPUT=${DOCS_OUTPUT:-"$SCRIPT_DIR/../../api-docs"}

# Pass VERBOSE_LOGGER=/dev/stdout to print verbose logs on the screen
VERBOSE_LOGGER=${VERBOSE_LOGGER:-/dev/null}

main() {
    step "Checkout source code at $VERSION"
    local worktree_path="$SCRIPT_DIR/.docs-source-code"
    local worktree_script_dir="$worktree_path/scripts/doc-generation"
    checkout_source_code "$worktree_path" "$VERSION"


    step "Build documentation"
    info "Install jazzy"
    local gemfile_path="$worktree_script_dir/Gemfile"
    install_jazzy "$gemfile_path"

    info "Prepare repository for jazzy"
    prepare_jazzy_build "$worktree_path"

    info "Build and parse"
    local jazzy_config_path="$worktree_script_dir/.jazzy.yaml"
    run_jazzy "$gemfile_path" "$jazzy_config_path" "$worktree_path" "$DOCS_OUTPUT"


    step "Patch documentation to include external references"
    info "Download MapboxCoreMaps documentation"
    download_coremaps_documentation "scripts/release/packager/versions.json" "$DOCS_OUTPUT/core"

    info "Download MapboxCommon documentation"
    download_common_documentation "scripts/release/packager/versions.json" "$DOCS_OUTPUT/common"

    info "Add dependency links to documentation"
    add_documentation_links "$DOCS_OUTPUT/index.html"

    finish "Successfully generated docs for $VERSION"
}


pre_check() {
    command -v gh >/dev/null 2>&1 || { echo >&2 "gh is required. brew install gh"; exit 1; }

    command -v jq >/dev/null 2>&1 || { echo >&2 "jq is required. brew install jq"; exit 1; }

    # Check gh has read auth – mbx-ci github writer token
    gh auth status
}

install_jazzy() {
    if [[ $# != 1 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        bundle install --gemfile "$1"
    } &> "$VERBOSE_LOGGER"
}

checkout_source_code() {
    if [[ $# != 2 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        local new_worktree_path="$1"
        local git_ref="$2"

        git worktree add "$new_worktree_path" "$git_ref"
        # shellcheck disable=SC2064
        trap "git worktree remove $1 --force" INT TERM HUP EXIT
        git -C "$1" submodule update --init
    } &> "$VERBOSE_LOGGER"
}

prepare_jazzy_build() {
    if [[ $# != 1 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        rm -rf "$1/*.xcodeproj"
        rm -rf "$1/*.xcworkspace"
    } &> "$VERBOSE_LOGGER"
}

run_jazzy() {
    if [[ $# != 4 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        local gemfile_path=$1
        local jazzy_config_path=$2
        local worktree_path=$3
        local output_dir=$4

        rm -rf "$output_dir"
        bundle exec --gemfile "$gemfile_path" \
            jazzy \
                --source-directory "$3" \
                --config "$jazzy_config_path" \
                --module-version "$VERSION" \
                --output "$output_dir"
    } &> "$VERBOSE_LOGGER"
}

download_coremaps_documentation() {
    if [[ $# != 2 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        set -x
        documentation_version=$(jq --raw-output ".MapboxCoreMaps" "$1")
        
        filename="MapboxCoreMaps-iOS-API-Reference.zip"
        rm "$filename" || true
        gh release download "maps-v$documentation_version" --pattern="$filename" --repo mapbox/mapbox-gl-native-internal

        unzip "$filename" -d "$2"
        rm "$filename" || true
        set +x
    } &> "$VERBOSE_LOGGER"
}

download_common_documentation() {
    if [[ $# != 2 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        set -x
        documentation_version=$(jq --raw-output ".MapboxCommon" "$1")
        
        filename="ios-api-reference.zip"
        rm "$filename" || true
        gh release download "v$documentation_version" --pattern="$filename" --repo mapbox/mapbox-sdk-common

        unzip "$filename" -d "$2"
        rm "$filename" || true
        set +x
    } &> "$VERBOSE_LOGGER"
}

add_documentation_links() {
    if [[ $# != 1 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi
    {
        search_regex="</ul>\n.*?</nav>"
        framework_links_html='<li class="nav-group-name" data-name="Frameworks">
                <a class="small-heading" href="Frameworks.html">Frameworks<span class="anchor-icon" /></a>
                <ul class="nav-group-tasks">
                <li class="nav-group-task" data-name="MapboxCoreMaps">
                    <a title="MapboxCoreMaps" class="nav-group-task-link" href="./core/index.html">MapboxCoreMaps</a>
                </li>
                <li class="nav-group-task" data-name="MapboxCommon">
                    <a title="MapboxCommon" class="nav-group-task-link" href="./common/index.html">MapboxCommon</a>
                </li>
                </ul>
            </li>
            </ul>
        </nav>'
        replace_regex_in_file "$search_regex" "$framework_links_html" "$1"
    } &> "$VERBOSE_LOGGER"
}

print_usage () {
    cat <<HELP_USAGE
Usage:
        $0 [-v] [-o output_folder] [-t git_tag]
        $0 -c

    -v  Enable verbose mode
    -o  Option to change default output directory
        Defaults: api-doc in repo root
    -t  Git tag to checkout
    -c  Run pre-checks to confirm that script has access to all dependent tools
HELP_USAGE
}

while getopts 'vo:t:c' flag; do
case "${flag}" in
    v) VERBOSE_LOGGER=/dev/stdout ;;
    o) DOCS_OUTPUT="$OPTARG" ;;
    t) VERSION="$OPTARG" ;;
    c) pre_check; exit 0 ;;
    *) print_usage
    exit 1 ;;
esac
done

main