#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHON_BIN="${ARCHON_BIN:-$HOME/.local/bin/archon}"

if ! command -v agent >/dev/null 2>&1; then
  echo "FAIL: Cursor CLI (agent) not found. Run ./scripts/bootstrap.sh"
  exit 1
fi

AUTH_OK=0
if [[ -n "${CURSOR_API_KEY:-}" ]]; then AUTH_OK=1; fi
if agent status 2>/dev/null | grep -qi 'logged in'; then AUTH_OK=1; fi
if [[ "$AUTH_OK" -ne 1 ]]; then
  echo "FAIL: Cursor not authenticated. Run: agent login"
  exit 1
fi

if [[ ! -x "$ARCHON_BIN" ]]; then
  echo "WARN: $ARCHON_BIN missing — using system archon if available"
  ARCHON_BIN="$(command -v archon || true)"
fi
if [[ -z "$ARCHON_BIN" ]]; then
  echo "FAIL: No archon binary. Run ./scripts/bootstrap.sh"
  exit 1
fi

echo "==> Validate workflows"
"$ARCHON_BIN" validate workflows --cwd "$REPO_ROOT" || true
"$ARCHON_BIN" workflow list --cwd "$REPO_ROOT"

echo "==> Run cursor-smoke workflow (native Cursor provider)"
set +e
"$ARCHON_BIN" workflow run cursor-smoke --cwd "$REPO_ROOT" --no-worktree \
  "Confirm tests/smoke.test.ts exists and all smoke tests pass; commit only if you changed the file"
CODE=$?
set -e

if [[ "$CODE" -ne 0 ]]; then
  echo "FAIL: cursor-smoke workflow exited $CODE"
  exit "$CODE"
fi

echo "PASS: Tier C smoke test completed in $REPO_ROOT"
