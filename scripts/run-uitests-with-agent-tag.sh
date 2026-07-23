#!/usr/bin/env bash
#
# Run the Examples app's XCUITest suite on a simulator, forwarding a detected
# AI coding-agent id (see agent-detect.sh) into the app process so it can be
# verified end-to-end that outbound Mapbox requests carry an `agent/<id>`
# token in their User-Agent header.
#
# This is test-tooling only - it has no effect on, and is not part of, the
# production SDK or a normal (non-XCUITest) app run.
#
# How the id reaches the app process:
#   1. This script detects the agent id from *this* host shell's environment
#      and passes it to `xcodebuild test` as `TEST_RUNNER_MAPBOX_AGENT=<id>`.
#      Xcode automatically strips the `TEST_RUNNER_` prefix and exposes the
#      remainder (`MAPBOX_AGENT`) as an environment variable of the *test
#      runner* process (i.e. `ProcessInfo.processInfo.environment` inside the
#      XCUITest target).
#   2. The XCUITest setup (see `Tests/ExamplesUITests/ExamplesUITests.swift`)
#      reads `MAPBOX_AGENT` from its own environment and copies it into
#      `XCUIApplication().launchEnvironment["MAPBOX_AGENT"]` before `.launch()`
#      - the app under test does not automatically inherit the test runner's
#      environment, so this explicit copy is required.
#   3. The app process (and therefore Common's HttpService) reads
#      `MAPBOX_AGENT` via `getenv`/`ProcessInfo` as it would in any other
#      context.
#
# If no agent is detected, no TEST_RUNNER_MAPBOX_AGENT argument is passed at
# all, so the run behaves exactly as it did before this tooling existed.
#
# Usage:
#   scripts/run-uitests-with-agent-tag.sh
#
# Optional environment overrides:
#   SCHEME       (default: Examples)
#   TEST_PLAN    (default: "Examples no unit tests")
#   DESTINATION  (default: "platform=iOS Simulator,name=iPhone 16")

set -eou pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

SCHEME="${SCHEME:-Examples}"
TEST_PLAN="${TEST_PLAN:-Examples no unit tests}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

AGENT_ID="$("$SCRIPT_DIR/agent-detect.sh")"

XCODEBUILD_ARGS=(
  test
  -project "$SCRIPT_DIR/../Examples.xcodeproj"
  -scheme "$SCHEME"
  -testPlan "$TEST_PLAN"
  -destination "$DESTINATION"
)

if [[ -n "$AGENT_ID" ]]; then
  echo "agent-detect: forwarding TEST_RUNNER_MAPBOX_AGENT=$AGENT_ID"
  XCODEBUILD_ARGS+=("TEST_RUNNER_MAPBOX_AGENT=$AGENT_ID")
else
  echo "agent-detect: no coding agent detected; running without agent tag forwarding"
fi

set -x
xcodebuild "${XCODEBUILD_ARGS[@]}"
