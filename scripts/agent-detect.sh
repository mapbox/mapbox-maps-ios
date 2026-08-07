#!/usr/bin/env bash
#
# Detect the AI coding agent (if any) driving the *host* shell that is about
# to invoke `xcodebuild test` (e.g. a Claude Code, Codex, or Cursor session
# running on a developer's or CI machine).
#
# This is test-tooling only, used to forward a detected agent id into an
# XCUITest simulator run so it can be verified that Mapbox requests made by
# the app under test carry an `agent/<id>` token in their User-Agent header.
# It has no effect on, and is never invoked by, a normal (non-XCUITest) app
# run or the production SDK.
#
# Ported from mapbox-sdk-js's `lib/helpers/agent-detect.js` (that repo's
# canonical implementation of this allowlist - keep the two in sync).
# Canonical origin of the allowlist itself: HuggingFace's public
# `agent-harnesses.ts` registry.
#
# Prints the detected agent id to stdout (and nothing else) when a match is
# found; prints nothing when no agent is detected. Always exits 0: an
# unexpected error while reading the environment must never fail the
# caller's build/test invocation, so no condition in this script should be
# treated as fatal.
#
# Usage:
#   agent_id="$(scripts/agent-detect.sh)"

set -uo pipefail # deliberately not `-e` - see note above about never failing

# A safe charset for an agent id that ends up appended to a User-Agent header:
# fallback env vars below are not validated by whoever sets them, so a value
# like $'foo\nbar: injected' must be rejected here rather than reaching
# xcodebuild/the app process as-is.
SAFE_FALLBACK_REGEX='^[A-Za-z0-9_.-]{1,64}$'

# trim VALUE -> VALUE with leading/trailing whitespace removed.
trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

# is_set VAR_NAME -> true (0) if VAR_NAME exists in the environment with a
# non-empty, non-whitespace-only value.
is_set() {
  local name="$1"
  local value
  value="$(trim "${!name-}")"
  [[ -n "$value" ]]
}

# is_equal VAR_NAME EXPECTED -> true (0) if VAR_NAME's value equals EXPECTED
# exactly (no trimming).
is_equal() {
  local name="$1"
  local expected="$2"
  [[ "${!name-}" == "$expected" ]]
}

# Scans the environment for a matching agent indicator. Table order (as
# checks below) is precedence order - the first entry with any matching
# condition wins.
detect_agent() {
  if is_set ANTIGRAVITY_AGENT; then echo "antigravity"; return; fi
  if is_set AUGMENT_AGENT; then echo "augment-cli"; return; fi
  if is_set CLINE_ACTIVE; then echo "cline"; return; fi
  if is_set CLAUDE_CODE_IS_COWORK; then echo "cowork"; return; fi
  if is_set CLAUDECODE || is_set CLAUDE_CODE; then echo "claude-code"; return; fi
  if is_set CODEX_SANDBOX || is_set CODEX_CI || is_set CODEX_THREAD_ID; then echo "codex"; return; fi
  if is_set CRUSH; then echo "crush"; return; fi
  if is_set GEMINI_CLI; then echo "gemini-cli"; return; fi
  if is_set COPILOT_MODEL || is_set COPILOT_ALLOW_ALL || is_set COPILOT_GITHUB_TOKEN; then echo "github-copilot"; return; fi
  if is_set GOOSE_TERMINAL; then echo "goose"; return; fi
  if is_set HERMES_SESSION_ID; then echo "hermes-agent"; return; fi
  if is_set KILOCODE_FEATURE; then echo "kilo-code"; return; fi
  if is_set AGENT_CONTEXT_OUT; then echo "kiro"; return; fi
  if is_set OPENCLAW_SHELL; then echo "openclaw"; return; fi
  if is_set OPENCODE_CLIENT; then echo "opencode"; return; fi
  if is_set PI_CODING_AGENT; then echo "pi"; return; fi
  if is_set REPL_ID; then echo "replit"; return; fi
  if is_set TRAE_AI_SHELL_ID; then echo "trae"; return; fi
  if is_equal VTCODE "1"; then echo "vtcode"; return; fi
  if is_equal TERM_PROGRAM "WarpTerminal"; then echo "warp"; return; fi
  if is_set ZED_TERM; then echo "zed"; return; fi
  if is_set CURSOR_AGENT; then echo "cursor-cli"; return; fi
  if is_set CURSOR_TRACE_ID; then echo "cursor"; return; fi

  # Checked only if nothing above matched. First candidate with a non-empty
  # (after trimming) value matching SAFE_FALLBACK_REGEX wins; an unsafe or
  # empty value falls through to the next var rather than being returned
  # as-is.
  local name candidate
  for name in AI_AGENT AGENT; do
    candidate="$(trim "${!name-}")"
    if [[ -n "$candidate" && "$candidate" =~ $SAFE_FALLBACK_REGEX ]]; then
      echo "$candidate"
      return
    fi
  done
}


# Lightweight regression check for detect_agent's precedence/fallback rules,
# run in a subshell per case so no case leaks environment into the next one.
# Usage: scripts/agent-detect.sh --self-test
run_self_test() {
  local failures=0
  local description="$1"
  local expected="$2"
  shift 2
  local actual
  actual="$(env -i HOME="$HOME" PATH="$PATH" "$@" bash "${BASH_SOURCE[0]}")"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: $description - expected '$expected', got '$actual'"
    return 1
  fi
  echo "OK: $description"
  return 0
}

self_test() {
  local failures=0

  run_self_test "no agent vars -> nothing detected" "" || ((failures++))
  run_self_test "CLAUDECODE=1 -> claude-code" "claude-code" CLAUDECODE=1 || ((failures++))
  run_self_test "CURSOR_TRACE_ID set -> cursor" "cursor" CURSOR_TRACE_ID=abc123 || ((failures++))
  run_self_test "table order: claude-code beats cursor when both set" "claude-code" \
    CLAUDECODE=1 CURSOR_TRACE_ID=abc || ((failures++))
  run_self_test "VTCODE=0 does not match (exact-equality check)" "" VTCODE=0 || ((failures++))
  run_self_test "VTCODE=1 -> vtcode" "vtcode" VTCODE=1 || ((failures++))
  run_self_test "TERM_PROGRAM=WarpTerminal -> warp" "warp" TERM_PROGRAM=WarpTerminal || ((failures++))
  run_self_test "fallback AGENT with a safe value is used" "my-custom-agent" \
    AGENT="my-custom-agent" || ((failures++))
  run_self_test "fallback AI_AGENT takes precedence over AGENT" "agent-one" \
    AI_AGENT="agent-one" AGENT="agent-two" || ((failures++))
  run_self_test "whitespace-only fallback value is rejected" "" AI_AGENT="   " || ((failures++))
  run_self_test "unsafe fallback value (header-injection shape) is rejected" "" \
    AGENT=$'evil\nInjected: yes' || ((failures++))

  if ((failures > 0)); then
    echo "$failures self-test case(s) failed"
    return 1
  fi
  echo "All self-test cases passed"
  return 0
}

if [[ "${1-}" == "--self-test" ]]; then
  self_test
  exit $?
fi

detect_agent
exit 0
