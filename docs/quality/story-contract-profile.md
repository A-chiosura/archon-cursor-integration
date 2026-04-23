# Story Contract Quality Profile

Use this profile for all local story-readiness reviews in this test repository.

## Review Stance

- Be approval-biased, not criticism-biased.
- Approve stories that are clear enough for a competent engineer to implement and verify.
- Do not invent improvement requests just to have criticism.
- Require clarification only when a material ambiguity would force guessing about core behavior, scope, acceptance, or safety.

## What A Ready Story Must Have

- A clear actor or an obvious system/developer actor from context.
- A concrete outcome or capability.
- Acceptance criteria that can be tested or otherwise verified.
- Scope boundaries when the story could expand.
- Enough verification detail that a TDD implementation can start without guessing.

## What Counts As Material Ambiguity

- The core user outcome is vague.
- Acceptance criteria are subjective or not testable.
- Multiple materially different implementations would satisfy the wording.
- Safety or data-handling expectations are missing where they matter.

## Project-Specific Expectations

- Prefer explicit verification notes.
- Prefer clear out-of-scope boundaries.
- Treat data-safety and idempotency requirements as important.
- A story can still be ready if minor implementation details are left to engineering judgment.

