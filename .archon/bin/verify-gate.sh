#!/usr/bin/env bash
set -euo pipefail

PHASE="${1:?phase required}"

phase_file=".cursor/workflow-phase"
if [[ -f "$phase_file" ]]; then
  current="$(tr -d '[:space:]' < "$phase_file")"
else
  current=""
fi

has_test_files() {
  find . -type f \( -name '*test*' -o -name '*spec*' \) \
    ! -path './.git/*' ! -path './node_modules/*' ! -path './.archon/*' | grep -q .
}

latest_commit_msg() {
  git log -1 --pretty=%s 2>/dev/null || true
}

case "$PHASE" in
  pre)
    [[ -n "${ARGUMENTS:-}" ]] || { echo "Missing workflow arguments" >&2; exit 1; }
    git rev-parse --is-inside-work-tree >/dev/null
    echo "Pre-gate OK"
    ;;

  tdd)
    has_test_files || { echo "No test files found after TDD phase" >&2; exit 1; }
    msg="$(latest_commit_msg)"
    [[ "$msg" == test:* ]] || [[ "$msg" == *test* ]] || { echo "Expected test commit, got: $msg" >&2; exit 1; }
    echo "TDD gate OK"
    ;;

  implement)
    if command -v npm >/dev/null 2>&1 && [[ -f package.json ]]; then
      npm test
    elif command -v bun >/dev/null 2>&1 && [[ -f package.json ]]; then
      bun test
    else
      echo "No npm/bun test runner configured; skipping automated test command"
    fi
    echo "Implement gate OK"
    ;;

  refactor)
    if command -v npm >/dev/null 2>&1 && [[ -f package.json ]]; then
      npm test
    elif command -v bun >/dev/null 2>&1 && [[ -f package.json ]]; then
      bun test
    fi
    echo "Refactor gate OK"
    ;;

  pr)
    if command -v gh >/dev/null 2>&1; then
      gh pr view --json url -q .url >/dev/null 2>&1 || {
        echo "No open PR found for current branch" >&2
        exit 1
      }
    else
      echo "gh not installed; skipping PR URL verification"
    fi
    echo "PR gate OK"
    ;;

  smoke)
    has_test_files || { echo "Smoke: no test file created" >&2; exit 1; }
    git log -1 --oneline >/dev/null
    echo "Smoke gate OK"
    ;;

  *)
    echo "Unknown verify phase: $PHASE" >&2
    exit 1
    ;;
esac
