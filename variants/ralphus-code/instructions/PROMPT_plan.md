0a. **Verify specs directory**: Run `ls specs/` to confirm it exists. If missing, error: "specs/ directory required. Create specs/*.md files first."
0b. Study `specs/*` using parallel explore agents (fire multiple background_task calls).
0c. Study @IMPLEMENTATION_PLAN.md (if present). If missing, use @IMPLEMENTATION_PLAN_REFERENCE.md as a format guide.
0d. Run `ls` to detect source directory (`src/`, `Sources/`, `lib/`, `app/`) if unknown.
0e. Study @AGENTS.md, README.md, VISION.md, DESIGN.md, or docs/* to understand project goals and vision.

1. Use parallel explore agents to study source code and compare against `specs/*`. Consult Oracle to analyze findings, prioritize tasks, and create/update @IMPLEMENTATION_PLAN.md as a prioritized list. Search for TODOs, placeholders, skipped tests, inconsistent patterns. Consider what's needed to achieve the project's stated goals.

**Task Granularity: Cohesive Units**
Break phases into atomic, deployable tasks. Each task must be a **complete logic unit** (e.g., "Implement POST /login with tests", not "Add types").
- Scope: 1 feature/endpoint + tests + verification.
- Constraint: Must be implementable in one continuous session (~30 mins).
- Avoid: Massive refactors or dependent chains without intermediate working states.

**Task Batching Rules:**
1. One task = one thing you can test in isolation
2. Multiple functions in the same file = usually one task
3. Multiple files with shared purpose = one task if tested together
4. Config files that follow the same pattern = one task

**Anti-patterns:**
- One task per function (too granular)
- One task per file (too granular if files are related)
- Tasks with no clear test criteria

**Target:** 15-25 tasks per feature. If you have 40+ tasks, you're too granular—re-group before continuing.

**Self-check:** Review task count before emitting PLAN_COMPLETE. Consolidate if needed.

2. If functionality is missing from specs but needed for project goals, search first to confirm it doesn't exist, then author the specification at specs/FILENAME.md and document the plan in @IMPLEMENTATION_PLAN.md.

IMPORTANT: Plan only. Do NOT implement. Confirm with code search before assuming anything is missing.

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation or approval. NEVER ask "Would you like me to...?" or "Should I proceed?". Just do the work and output the completion signal when done.

When planning is complete, output `<promise>PLAN_COMPLETE</promise>` and STOP.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @IMPLEMENTATION_PLAN.md in the project root.
