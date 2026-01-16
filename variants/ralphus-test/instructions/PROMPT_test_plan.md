# Ralphus Test - Planning Mode

You are preparing a test specification for autonomous test creation.

## Reference Templates (ATTACHED)

1. **@TEST_PLAN_REFERENCE.md** — REQUIRED: Progress tracking header and phase breakdown for the master plan.
2. **@SPEC_FORMAT_REFERENCE.md** — Required table structure for individual test specs in `test-specs/`.
3. **@SUMMARY_HEADER_REFERENCE.md** — Progress tracking header format with percentage.
4. **@TEST_UTILITIES_REFERENCE.md** — Priority 0 infrastructure section.

## Phase 0: Discovery

0a. **Verify test-specs directory**: Run `ls test-specs/` to confirm it exists.
0b. Study @TEST_PLAN.md (if present). If missing, use @TEST_PLAN_REFERENCE.md as a format guide.
0c. Study `test-specs/*.md` and existing tests.
0d. Identify framework (vitest/jest/mocha) from package.json.

## Phase 1: Initialize/Update Test Plan

1. **Create/Update @TEST_PLAN.md**: Using @TEST_PLAN_REFERENCE.md, list all test specifications in `test-specs/`. Update progress counts.

2. **Normalize Test Specs**: Convert tables in `test-specs/*.md` to the format in @SPEC_FORMAT_REFERENCE.md. Ensure unique Test IDs.

## Phase 2: Break Down Complex Tests

For each test case, evaluate:
- Can this be implemented in ONE test function (<50 lines)?
- Does it require setup that other tests also need?
- Is the expected behavior clear and testable?

**If too complex**: Break into atomic units per the attached @SPEC_FORMAT_REFERENCE.md.

**If needs shared setup**: Add to Priority 0 utilities section.

## Phase 3: Identify Prerequisites

If the spec lacks a test utilities section, create one following the attached @TEST_UTILITIES_REFERENCE.md.

Common utilities to identify:
- Session/auth mocking
- Database mocking (Prisma, etc.)
- API mocking (MSW handlers)
- Factory functions for test data

## Phase 4: Validate Clarity

For each test, ensure:
- [ ] Test ID is unique (format: `PREFIX-NNN`)
- [ ] Test case describes the scenario (not just "it works")
- [ ] Expected result is verifiable
- [ ] File path is specified

**Flag unclear tests**: Add `NEEDS_CLARIFICATION: [reason]` in Notes column and mark as `[!]`.

## Phase 5: Add Summary Header

Add a progress tracking section at the top of each spec in `test-specs/` per the attached @SUMMARY_HEADER_REFERENCE.md.

## Phase 6: Commit and Complete

1. **Commit**: `git add . && git commit -m "Prepare test plan for Ralphus Test loop"`
2. **Output**: `<promise>PLAN_COMPLETE</promise>` and STOP.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not write test code yet. Plan only.
9999999. Do not update REFERENCE files. Only update @TEST_PLAN.md and `test-specs/*.md`.
