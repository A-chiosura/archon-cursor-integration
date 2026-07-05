#!/usr/bin/env bash
# Apply Cursor community provider into a local Archon checkout.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHON_DIR="${ARCHON_DIR:-$HOME/Projects/archon}"
PROVIDER_SRC="$ROOT/archon-provider/cursor"
PROVIDER_DST="$ARCHON_DIR/packages/providers/src/community/cursor"

if [[ ! -d "$ARCHON_DIR/.git" ]]; then
  echo "Archon checkout not found at $ARCHON_DIR"
  echo "Clone first: git clone https://github.com/coleam00/Archon.git \"$ARCHON_DIR\""
  exit 1
fi

mkdir -p "$PROVIDER_DST"
rsync -a --delete "$PROVIDER_SRC/" "$PROVIDER_DST/"

REGISTRY="$ARCHON_DIR/packages/providers/src/registry.ts"
if ! grep -q registerCursorProvider "$REGISTRY"; then
  python3 - "$REGISTRY" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()

import_anchor = "import { registerCopilotProvider } from './community/copilot/registration';"
call_anchor = "  registerCopilotProvider();"

if import_anchor not in text:
    sys.exit(f"import anchor not found in {path}")
if call_anchor not in text:
    sys.exit(f"call anchor not found in {path}")

text = text.replace(
    import_anchor,
    import_anchor + "\nimport { registerCursorProvider } from './community/cursor/registration';",
    1,
)
text = text.replace(
    call_anchor,
    call_anchor + "\n  registerCursorProvider();",
    1,
)
path.write_text(text)
print("Patched registry.ts")
PY
else
  echo "registry.ts already contains registerCursorProvider"
fi

DOCTOR="$ARCHON_DIR/packages/cli/src/doctor.ts"
if [[ -f "$DOCTOR" ]] && ! grep -q 'cursor.binary' "$DOCTOR"; then
  cat >> "$DOCTOR.cursor.patch" <<'PATCH'
# Manual doctor patch (apply if not auto-merged):
# import { assertCursorBinaryExists, resolveCursorAuth } from '@archon/providers/community/cursor';
# Add checks:
#   assertCursorBinaryExists(config?.assistants?.cursor?.cursorBinaryPath)
#   resolveCursorAuth() → warn if !ok
PATCH
  echo "Wrote doctor patch notes to packages/cli/src/doctor.ts.cursor.patch"
fi

echo "Cursor provider applied to $PROVIDER_DST"
