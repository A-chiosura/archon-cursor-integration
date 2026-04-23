# Story 35: Show Data Import Status

## Story

As a developer running local data imports, I want a status summary after each import so that I can quickly see whether the import succeeded, failed, or produced partial results.

## Acceptance Criteria

- The import command prints a final status of `success`, `partial`, or `failed`.
- The summary includes row counts for inserted, skipped, and failed rows.
- Failed rows include a concise reason category.
- The command exits with code `0` for `success` and `partial`.
- The command exits with non-zero status for `failed`.

## Out Of Scope

- Web UI changes.
- Long-term import history storage.
- Automatic retry behavior.

## Verification

- Unit test status classification.
- Integration test a small synthetic import file containing valid, skipped, and invalid rows.
- CI must run the import-status test without requiring external paid services.

