#!/bin/bash

__HELPERS_UTILS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Log a step with cyan text color
step() { >&2 echo -e "\033[1m\033[36m* $*\033[0m"; }

# Log a step with gray text color
info() { >&2 echo -e "\033[1m\033[30m- $*\033[0m"; }

# Log an informational warning with yellow text color
warning() { >&2 echo -e "\033[1m\033[33m! $*\033[0m"; }

# Log an error with red text color
error() { >&2 echo -e "\033[1m\033[31mⅹ $*\033[0m"; }

# Log the completion with green text color
finish() { >&2 echo -e "\033[1m\033[32m✔ $*\033[0m"; }


replace_regex_in_file() {
    if [[ $# != 3 ]]; then
        echo "Illegal number of parameters in ${FUNCNAME[0]}"
        exit 1
    fi

    local oldText=$1
    local newText=$2
    local filepath=$3

    local replace_text_script_path="$__HELPERS_UTILS_SCRIPT_DIR/replace-regex-in-file.py"

    "$replace_text_script_path" --old "$oldText"  --new "$newText" "$filepath"
}