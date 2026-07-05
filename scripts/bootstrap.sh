#!/usr/bin/env bash
# Tier C bootstrap: Cursor CLI + Archon fork + provider + custom binary
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHON_DIR="${ARCHON_DIR:-$HOME/Projects/archon}"
LOCAL_BIN="$HOME/.local/bin"

echo "==> [1/6] Install Cursor CLI (agent)"
if ! command -v agent >/dev/null 2>&1; then
  curl -fsSL https://cursor.com/install | bash
fi
mkdir -p "$LOCAL_BIN"
if command -v agent >/dev/null 2>&1; then
  echo "Cursor CLI: $(command -v agent)"
else
  echo "WARN: agent not on PATH after install. Add ~/.local/bin to PATH."
fi

echo "==> [2/6] Clone Archon if missing"
if [[ ! -d "$ARCHON_DIR/.git" ]]; then
  git clone --depth 1 https://github.com/coleam00/Archon.git "$ARCHON_DIR"
fi

echo "==> [3/6] Apply Cursor provider from this repo"
ARCHON_DIR="$ARCHON_DIR" bash "$ROOT/scripts/apply-archon-cursor-provider.sh"

echo "==> [4/6] Install Archon dependencies"
cd "$ARCHON_DIR"
if command -v bun >/dev/null 2>&1; then
  bun install
else
  echo "bun required. Install: https://bun.sh"
  exit 1
fi

echo "==> [5/6] Build custom Archon binary"
bun run build:binaries

echo "==> [6/6] Install archon binary"
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
  BUILT="$ARCHON_DIR/dist/binaries/archon-darwin-arm64"
else
  BUILT="$ARCHON_DIR/dist/binaries/archon-darwin-x64"
fi
if [[ ! -f "$BUILT" ]]; then
  echo "Could not find built archon binary at $BUILT. Build manually in $ARCHON_DIR"
  exit 1
fi
install -m 755 "$BUILT" "$LOCAL_BIN/archon"
# Legacy alias — same binary; prefer `archon` everywhere
install -m 755 "$BUILT" "$LOCAL_BIN/archon-cursor"
echo "Installed: $LOCAL_BIN/archon (primary) and $LOCAL_BIN/archon-cursor (same build)"

echo
echo "Bootstrap complete."
echo "Repo root: $ROOT"
echo "Next (required once): agent login   OR   export CURSOR_API_KEY=..."
echo "Then run: $ROOT/scripts/smoke-test.sh"
