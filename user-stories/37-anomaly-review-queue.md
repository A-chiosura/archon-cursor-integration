# Story 37: Add A Data Anomaly Review Queue

## Story

As a market-data researcher, I want detected data anomalies to appear in a review queue so that I can inspect data-quality problems without changing the raw imported tick data.

## Acceptance Criteria

- Detected anomalies are written to a separate diagnostics table or artifact.
- Raw imported market-data rows are never mutated by the review queue.
- Each anomaly includes symbol, timestamp range, anomaly type, severity, and a short explanation.
- Running the anomaly detection twice on the same input is idempotent and does not create duplicate queue entries.
- The review queue can filter anomalies by symbol and severity.

## Out Of Scope

- Human approval workflow for correcting data.
- Automatic repair of bad ticks.
- UI bulk actions.

## Verification

- Synthetic anomaly test covering at least price jump, duplicate timestamp, invalid volume, and bid greater than ask.
- Idempotency test that runs detection twice and confirms no duplicate findings.
- Isolation test proving raw input data is unchanged after queue generation.
- CI must run the anomaly tests with local test data.

