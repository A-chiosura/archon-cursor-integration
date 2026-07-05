# Upstream contribution checklist

1. Copy `archon-provider/cursor/` → `packages/providers/src/community/cursor/`
2. Add `registerCursorProvider()` to `registerCommunityProviders()` in `registry.ts`
3. Add doctor checks in `packages/cli/src/doctor.ts`
4. Add `CursorProviderDefaults` to `packages/providers/src/types.ts` (optional typed export)
5. Add tests under `packages/providers/src/community/cursor/*.test.ts`
6. Document in `docs/providers/cursor.md`
7. Open PR to https://github.com/coleam00/Archon with description linking OpenClaw + Cursor use case

## PR title suggestion

`feat(providers): add Cursor community provider (headless CLI bridge)`

## Notes for maintainers

- No static imports from Cursor SDK (CLI subprocess only)
- Capabilities start conservative; hooks/skills load from repo cwd via Cursor CLI
- Session resume via `--resume` + `.archon/cursor-sessions/` sidecar store
