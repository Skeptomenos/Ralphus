# Ralphus Test - Planning Mode

You are preparing a test specification for autonomous test creation.

## Reference Templates (ATTACHED)

1. **@TEST_PLAN_REFERENCE.md** — REQUIRED: Progress tracking header and phase breakdown.
2. **@SPEC_FORMAT_REFERENCE.md** — Required table structure for individual test specs.
3. **@SUMMARY_HEADER_REFERENCE.md** — Progress tracking header format with percentage.
4. **@TEST_UTILITIES_REFERENCE.md** — Priority 0 infrastructure section.

## Phase 0: Discovery

0a. **Verify test-specs directory**: Run `ls test-specs/` to confirm it exists.
0b. Study @TEST_PLAN.md (if present). If missing, use @TEST_PLAN_REFERENCE.md.
0c. Study `test-specs/*.md` and existing tests.
0d. Identify framework (vitest/jest/mocha) from package.json.

## Phase 1: Initialize/Update Test Plan

1. **Create/Update @TEST_PLAN.md**: Using @TEST_PLAN_REFERENCE.md, list all test specifications in `test-specs/`. Update progress counts.

2. **Normalize Test Specs**: Convert tables in `test-specs/*.md` to the format in @SPEC_FORMAT_REFERENCE.md. Ensure unique Test IDs.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not write test code yet. Plan only.
9999999. Do not update REFERENCE files. Only update @TEST_PLAN.md and `test-specs/*.md`.

## Phase 6: Commit and Complete

1. **Commit**: `git add . && git commit -m "Prepare test spec for Ralphus Test loop"`

2. **Output**: `<promise>PLAN_COMPLETE</promise>` and STOP.

## Rules

**Plan only. Do NOT write any test code yet.**

## Agent Delegation

| Task | Agent | Invocation |
|------|-------|------------|
| Find test files/patterns | explore | `background_task(agent="explore", ...)` |
| Find test framework docs | librarian | `background_task(agent="librarian", ...)` |
| Complex test breakdown | oracle | `task(subagent_type="oracle", ...)` |

## Guardrails

99999. Every test must have a unique ID (PREFIX-NNN format)
999999. Every test must have a clear expected result
9999999. Break down tests that would require >50 lines
99999999. Identify shared utilities before individual tests
999999999. Preserve the original priority order
