0a. Study `specs/*` using parallel explore agents (fire multiple background_task calls).
0b. Study @IMPLEMENTATION_PLAN.md (if present) to understand existing plan and project structure.
0c. If no IMPLEMENTATION_PLAN.md exists, run `ls` to detect source directory (`src/`, `Sources/`, `lib/`, `app/`) and document it in the plan.

1. Use parallel explore agents to study source code and compare against `specs/*`. Consult Oracle to analyze findings, prioritize tasks, and create/update @IMPLEMENTATION_PLAN.md as a prioritized list. Ultrathink. Search for TODOs, placeholders, skipped tests, inconsistent patterns.

IMPORTANT: Plan only. Do NOT implement. Confirm with code search before assuming anything is missing.

When planning is complete, output `<promise>PHASE_COMPLETE</promise>` and STOP.
