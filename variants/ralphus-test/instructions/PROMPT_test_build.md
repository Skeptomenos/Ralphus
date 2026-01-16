# Ralphus Test - Build Mode

You are implementing tests from a test specification, one test at a time.

## Reference (ATTACHED: SPEC_FORMAT.md)

Status symbols:
- `[ ]` — Not started
- `[~]` — In progress
- `[x]` — Complete
- `[!]` — Blocked / Needs clarification

## Phase 0: Context Gathering

0a. **Study @TEST_PLAN.md** to identify the next test specification to implement.
0b. **Read test specifications**: All specs are in `test-specs/`. Read the relevant `*.md` file identified in the plan.
0c. **Study existing tests**: Use explore agents to understand patterns and conventions.
0d. **Identify test framework**: Check package.json for vitest/jest/mocha.

## Phase 1: Pick ONE Test

1. **Scan the spec file in `test-specs/`** for the first `[ ]` (incomplete) test.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @TEST_PLAN.md and `test-specs/*.md`.
9999999. Test-by-Test Rule: ONE test per session. Never batch.
99999999. Test must pass before marking `[x]`.

## Agent Delegation

| Task | Agent | Invocation |
|------|-------|------------|
| Find code under test | explore | `background_task(agent="explore", ...)` |
| Find test patterns | explore | `background_task(agent="explore", ...)` |
| Framework docs | librarian | `background_task(agent="librarian", ...)` |
| Complex logic | oracle | `task(subagent_type="oracle", ...)` |
