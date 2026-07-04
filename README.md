# archon-cursor-integration

Pilot repository for **Tier C**: governed software delivery with [Archon](https://github.com/coleam00/Archon) orchestrating a hard DAG and **Cursor CLI** executing code changes.

**GitHub:** https://github.com/A-chiosura/archon-cursor-integration  
**GitHub actor for automation:** `cicaptain` (org bot — not your personal account)

## Pipeline

```text
OpenClaw PO / control-room → Archon DAG → Cursor CLI (agent) → verify gates → GitHub PR
```

| Layer | Role |
|-------|------|
| **Archon** | Workflow engine, worktrees, hard exit-code gates |
| **Cursor** | Coding executor via `agent -p --force --trust` in bash nodes |
| **cicaptain** | GitHub identity for push, PR, and commits |
| **You (tgrytnes)** | Approve stories, review and merge PRs |

## Prerequisites

On your Mac:

- `archon-cursor` at `~/.local/bin/archon-cursor` (built from `~/archon-cursor-integration/scripts/bootstrap.sh`)
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

List workflows:

```bash
archon-cursor workflow list --cwd ~/Projects/archon-cursor-integration
```

### Smoke test

```bash
archon-cursor workflow run cursor-smoke \
  --cwd ~/Projects/archon-cursor-integration \
  --no-worktree "Add or update tests/smoke.test.ts and commit"
```

### Dev loop (isolated branch + worktree)

```bash
archon-cursor workflow run dev-loop-cursor \
  --cwd ~/Projects/archon-cursor-integration \
  --branch feature/my-story \
  "Describe the story and acceptance criteria here"
```

## Repository layout

```text
.archon/
  workflows/          # cursor-smoke, dev-loop-cursor (+ bundled Archon defaults)
  bin/                # run-cursor-step.sh, verify-gate.sh
  .env                # cicaptain GitHub token (local only, gitignored)
.cursor/
  hooks/              # blocks git push during TDD/implement/refactor phases
tests/                # smoke and feature tests
user-stories/         # optional local story markdown for readiness workflows
```

## Tooling repo (separate)

The **Archon + Cursor provider build** lives in your home directory, not this GitHub repo:

```text
~/archon-cursor-integration/    # scripts, provider source, bootstrap
~/Projects/archon/              # Archon fork with Cursor community provider
```

Run bootstrap and smoke from there:

```bash
cd ~/archon-cursor-integration
./scripts/bootstrap.sh
./scripts/smoke-test.sh
```

Set `PILOT_REPO=~/Projects/archon-cursor-integration` if needed (default after cleanup).

## Governance

Control-room policy and gates: `~/control-room/` (`ARCHON_GATE.md`, `WORKFLOW_POLICY.md`, DEC-0009).

Use `--branch <name>` for isolated work unless you explicitly need `--no-worktree`.

## Clone fresh

```bash
git clone git@github.com:A-chiosura/archon-cursor-integration.git ~/Projects/archon-cursor-integration
# Add .archon/.env with cicaptain token (see Prerequisites)
```
