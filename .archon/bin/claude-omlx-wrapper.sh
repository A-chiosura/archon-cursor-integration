#!/bin/bash
set -euo pipefail

if [[ -f "$HOME/.archon/.env" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$HOME/.archon/.env"
  set +a
fi

exec /Users/thomasfey-grytnes/.local/bin/claude "$@"

