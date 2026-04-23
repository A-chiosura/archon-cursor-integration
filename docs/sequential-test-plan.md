# Sequential Test Plan

Use this project to test orchestration behavior, not implementation quality.

## Manual Claude Prompt

```text
Run story readiness checks sequentially for stories 34, 35, 36, and 37.
Wait for each story check to finish before starting the next one.
Do not run them in parallel.
After each story finishes, report the verdict before starting the next story.
```

## Expected Behavior

Claude should start only one story check at a time.

Expected order:

```text
story 34 starts
story 34 finishes
story 35 starts
story 35 finishes
story 36 starts
story 36 finishes
story 37 starts
story 37 finishes
```

Expected story-quality verdicts:

```text
34 ready
35 ready
36 needs clarification
37 ready
```

## What This Tests

- Whether Claude follows a sequential instruction.
- Whether the controller model can coordinate simple workflow calls.
- Whether the quality gate is approval-biased for clear stories.
- Whether genuinely vague stories are sent to clarification.

