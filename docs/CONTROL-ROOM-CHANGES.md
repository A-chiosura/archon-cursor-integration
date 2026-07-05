# Control room updates for Cursor + Archon Tier C

Apply these edits to `~/control-room/` after bootstrap.

## WORKFLOW_POLICY.md — add to PO authorized workflows

- `dev-loop-cursor`
- `cursor-smoke`

## WORKFLOW_POLICY.md — add to Workflow Designer authorized workflows

- `dev-loop-cursor`
- `cursor-smoke`

## ARCHON_GATE.md — add Cursor section

```text
## Cursor provider (archon-cursor)

Custom Archon binary: ~/.local/bin/archon-cursor
Cursor CLI: ~/.local/bin/agent

Preflight:
  agent -p "Reply exactly CURSOR_GATE_OK"   # or CURSOR_API_KEY set
  archon-cursor doctor
  archon-cursor validate workflows --cwd <repo>

Default routing (pilot):
  default assistant: cursor
  workflows: dev-loop-cursor, cursor-smoke

Governed command:
  archon-cursor workflow run dev-loop-cursor --cwd <repo> --branch <branch> "<request>"
```

## DECISION_LOG.md — add row

| DEC-0009 | 2026-07-04 | Adopt Cursor as Archon execution provider via archon-cursor-integration Tier C | Thomas | dev pipeline | OpenClaw PO → Archon DAG → Cursor → GitHub | ARCHON_GATE.md, WORKFLOW_POLICY.md |
