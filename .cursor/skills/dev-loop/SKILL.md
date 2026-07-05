---
name: dev-loop
description: TDD-first dev loop for Archon + Cursor workflows. Use when running dev-loop-cursor or phased implementation.
---

# Dev loop skill

When executing a phased dev workflow:

1. Respect `.cursor/workflow-phase` — only do work allowed for that phase.
2. TDD phase: tests only, no production implementation, commit but do not push.
3. Implement phase: minimal code to pass tests, run tests, commit, no push.
4. Refactor phase: improve design, tests must stay green, commit, no push.
5. PR phase: push and open PR with test evidence.

If phase file is missing, ask which phase to run or infer from the user request.
