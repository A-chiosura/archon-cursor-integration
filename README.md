# archon-cursor-integration

**Tier C** integration repository: [Archon](https://github.com/coleam00/Archon) orchestrates a hard DAG; **Cursor CLI** executes code changes; OpenClaw governs dispatch via `~/control-room/`.

**GitHub:** https://github.com/A-chiosura/archon-cursor-integration  
**GitHub actor for automation:** `cicaptain` (org bot — not your personal account)

This repo is the **single source of truth** for workflows, gates, provider source, bootstrap scripts, and proof runs.

## Pipeline

```text
OpenClaw PO / control-room → Archon DAG → Cursor CLI (agent) → verify gates → GitHub PR
```

| Layer | Role |
|-------|------|
| **Archon** | Workflow engine, worktrees, hard exit-code gates |
| **Cursor** | Coding executor via native `provider: cursor` |
| **cicaptain** | GitHub identity for push, PR, and commits |
| **You (tgrytnes)** | Approve stories, review and merge PRs |

## Quick start

```bash
git clone git@github.com:A-chiosura/archon-cursor-integration.git ~/Projects/archon-cursor-integration
cd ~/Projects/archon-cursor-integration

# Add .archon/.env with cicaptain token (see Prerequisites)

./scripts/bootstrap.sh    # builds ~/.local/bin/archon from ~/Projects/archon fork
agent login               # or export CURSOR_API_KEY=...
./scripts/smoke-test.sh
```

## Prerequisites

On your Mac:

- **This repo** cloned to `~/Projects/archon-cursor-integration`
- **Archon fork** at `~/Projects/archon` (cloned/built by `bootstrap.sh`)
- `archon` at `~/.local/bin/archon` (installed by `bootstrap.sh`)
- Cursor CLI: `agent` on PATH, logged in (`agent login`)
- cicaptain token in **`.archon/.env`** (never commit this file):

  ```bash
  GH_TOKEN=github_pat_...
  GITHUB_TOKEN=github_pat_...
  ARCHON_GITHUB_ACTOR=cicaptain
  ```

- Fine-grained PAT must be **resource owner `A-chiosura`**, repo access granted, and **org-approved**

## Workflows

| Workflow | Purpose |
|----------|---------|
| `cursor-smoke` | Minimal end-to-end check: Cursor runs, writes a test, commit, gate passes |
| `dev-loop-cursor` | TDD → implement → refactor → open PR (8 nodes + verify gates) |

```bash
archon workflow list --cwd ~/Projects/archon-cursor-integration
```

### Smoke test

```bash
archon workflow run cursor-smoke \
  --cwd ~/Projects/archon-cursor-integration \
  --no-worktree "Add or update tests/smoke.test.ts and commit"
```

### Dev loop (isolated branch + worktree)

```bash
archon workflow run dev-loop-cursor \
  --cwd ~/Projects/archon-cursor-integration \
  --branch feature/my-story \
  "Describe the story and acceptance criteria here"
```

## Repository layout

```text
.archon/
  workflows/          # cursor-smoke, dev-loop-cursor (+ bundled Archon defaults)
  bin/                # verify-gate.sh (phase gates)
  .env                # cicaptain GitHub token (local only, gitignored)
.cursor/
  hooks/              # blocks git push during TDD/implement/refactor phases
  skills/             # dev-loop skill for Cursor agents
archon-provider/
  cursor/             # Cursor community provider (patched into ~/Projects/archon)
scripts/
  bootstrap.sh        # install Cursor CLI, build archon, apply provider
  smoke-test.sh       # end-to-end workflow smoke
  apply-archon-cursor-provider.sh
docs/                 # control-room notes, upstream PR checklist
tests/                # vitest smoke and feature tests
src/                  # minimal app code for dev-loop proof runs
user-stories/         # optional story markdown for readiness workflows
```

## Related paths (separate repos)

| Path | Role |
|------|------|
| `~/Projects/archon` | Archon upstream fork — provider patch target |
| `~/control-room/` | OpenClaw governance (`ARCHON_GATE.md`, `WORKFLOW_POLICY.md`) |

Legacy home path `~/archon-cursor-integration/` symlinks here if present.

## Governance

Control-room policy and gates: `~/control-room/` (DEC-0009, DEC-0010).

Use `--branch <name>` for isolated work unless you explicitly need `--no-worktree`.
