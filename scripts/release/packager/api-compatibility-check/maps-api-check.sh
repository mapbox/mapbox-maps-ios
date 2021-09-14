#!/usr/bin/env bash

set -eo pipefail

#
# Usage:
#   ./scripts/ios/maps-api-check.sh <current release tag (empty for branches)>
#

TAGGED_RELEASE_VERSION=$1

CURRENT_DIR=$(pwd)
ROOT_DIR="${CURRENT_DIR}/../.."
REPORT_DIR=${ROOT_DIR}/api_compat_report
mkdir -p ${REPORT_DIR}

if [[ -z ${TAGGED_RELEASE_VERSION} ]]; then
    LAST_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo $LAST_VERSION
    VERSION=$GITHUB_REF
else
    LAST_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1 --skip=1 --no-walk))
    echo $LAST_VERSION
    VERSION=$TAGGED_RELEASE_VERSION
fi

if [[ ! -d ~/mapbox-apidiff ]]; then
    git clone --depth 1 https://github.com/mapbox/apidiff ~/mapbox-apidiff
    pushd ~/mapbox-apidiff/apple/diffreport > /dev/null
    swift build
    echo "cloned"
    popd > /dev/null
fi

parse_json_report() {
    set -eo pipefail
    node - <<'EOF' "$1"
const fs = require('fs');
const data = fs.readFileSync(process.argv[2]).toString();
const report = JSON.parse(data);
const issues = Object.keys(report).reduce((acc, k) => {
    return report[k].reduce((acc, entry) => {
        const hasDuplicate = (diffType) => {
            return report[k].find(e => e.name === entry.name && e.diff === diffType);
        }
        if (entry.diff === "added" && !hasDuplicate("deletion")) {
            acc.minor++;
        }
        if (entry.diff === "deleted" && !hasDuplicate("addition")) {
            acc.major++;
        }
        if (entry.diff === "modified") {
            acc.unknown++;
        }
        return acc;
    }, acc);
}, {minor: 0, major: 0, unknown: 0});
console.log(`MAJOR_PROBLEMS=${issues.major}`);
console.log(`MINOR_PROBLEMS=${issues.minor}`);
console.log(`UNKNOWN_PROBLEMS=${issues.unknown}`);
EOF
}

compareAPI() {
    set -eo pipefail
    JSON_TMP_FILE=$(mktemp)
    pushd ~/mapbox-apidiff/ > /dev/null
    git fetch
    git checkout origin/jk/iphone-simulator
    src/apidiff $LAST_VERSION $VERSION swift ../../Apps/App.xcworkspace MapboxMaps > $JSON_TMP_FILE
    popd > /dev/null



    cat $JSON_TMP_FILE
    eval "$(parse_json_report ${JSON_TMP_FILE})"
    cat $JSON_TMP_FILE
    mv "${JSON_TMP_FILE}" ${REPORT_DIR}/api_compat.json

    if (( MAJOR_PROBLEMS > 0 )); then
        echo major
    elif (( MINOR_PROBLEMS > 0 )); then
        echo minor
    else
        echo patch
    fi
}

api_compat=$(compareAPI)
rm -rf ${TMPDIR}

${CURRENT_DIR}/api-compatibility-check/semver-check.sh "${VERSION}" "${LAST_VERSION}" "${api_compat}"
