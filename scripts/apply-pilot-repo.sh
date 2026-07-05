#!/usr/bin/env bash
# Deprecated — repo files are canonical; no template sync.
set -euo pipefail

echo "apply-pilot-repo.sh is deprecated."
echo "Workflow and gate files live in this repo (.archon/, .cursor/)."
echo "Run ./scripts/bootstrap.sh to build the Archon binary and apply the provider."
exit 0
