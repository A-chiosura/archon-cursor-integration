#!/usr/bin/env bash
set -euo pipefail

PHASE="${1:?phase required}"
REQUEST="${2:-}"

AGENT_BIN="${CURSOR_BIN_PATH:-${AGENT_BIN_PATH:-agent}}"
if ! command -v "$AGENT_BIN" >/dev/null 2>&1; then
  echo "Cursor CLI not found: $AGENT_BIN" >&2
  exit 1
fi

prompt_for_phase() {
  case "$PHASE" in
    tdd)
      cat <<EOF
Phase: TDD only for: $REQUEST
Rules:
- Write failing tests first
- Run tests and confirm they fail for the right reason
- Commit with message starting with 'test:'
- Do NOT implement production code beyond tests
- Do NOT push
EOF
      ;;
    implement)
      cat <<EOF
Phase: Implement for: $REQUEST
Rules:
- Make tests pass with minimal production code
- Run full test suite
- Commit with message starting with 'feat:' or 'fix:'
- Do NOT push
EOF
      ;;
    refactor)
      cat <<EOF
Phase: Refactor for: $REQUEST
Rules:
- Improve code quality without changing behavior
- Keep all tests green after each change
- Commit with message starting with 'refactor:'
- Do NOT push
EOF
      ;;
    pr)
      cat <<EOF
Phase: Pull request for: $REQUEST
Rules:
- Push current branch
- Open PR to main with gh
- Include test evidence in PR body
EOF
      ;;
    smoke)
      cat <<EOF
Smoke test: $REQUEST
Create or update tests/smoke.test.ts with one failing or passing test as requested.
Commit the change. Do not push.
EOF
      ;;
    *)
      echo "Unknown phase: $PHASE" >&2
      exit 1
      ;;
  esac
}

PROMPT="$(prompt_for_phase)"
"$AGENT_BIN" -p --force --trust --approve-mcps --workspace "$PWD" --output-format stream-json "$PROMPT"
