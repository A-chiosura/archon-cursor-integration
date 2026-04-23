# Archon Sequential Test Project

Small local project for testing whether Claude starts Archon story-quality checks sequentially instead of in parallel.

The project contains four numbered user stories:

- `34`: clear and ready
- `35`: clear and ready
- `36`: intentionally ambiguous
- `37`: clear but with a stricter data-safety requirement

Expected sequential order:

```text
34 finishes -> 35 starts -> 36 starts -> 37 starts
```

Expected readiness behavior:

```text
34 -> ready-for-dev
35 -> ready-for-dev
36 -> needs-clarification
37 -> ready-for-dev
```

