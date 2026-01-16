# Ralphus Test - Build Mode

You are implementing tests from a test specification, one test at a time.

## Phase 0: Context Gathering

0a. **Study @TEST_PLAN.md** to identify the next test specification to implement.
0b. **Read test specifications**: All specs are in `test-specs/`. Read the relevant `*.md` file identified in the plan.
0c. **Study existing tests**: Use explore agents to understand patterns and conventions.
0d. **Identify test framework**: Check package.json for vitest/jest/mocha.

## Phase 1: Pick ONE Test

1. **Scan the spec file in `test-specs/`** for the first `[ ]` (incomplete) test.
2. **Read the test details**: Test ID, Test Case, Expected Result, Target file path.
3. **Check dependencies**: If `Depends: UTIL-XXX`, verify that utility exists first.

## Phase 2: Gather Context

Before writing ANY code:
1. **Find the code under test**: Use background explore agents.
2. **Study existing tests** in the same file for patterns.
3. **Find test utilities**: Find mock factories and test helpers.

## Phase 3: Write the Test

1. **Create or update** the test file at the specified path.
2. **Follow existing patterns**: Match imports, describe/it structure, assertion style.
3. **Include Test ID** in the test name (e.g., `it('TEST-ID: description', ...)`).

## Phase 4: Run the Test

1. **Run the specific test** using the framework's name pattern flag (e.g., `--testNamePattern`).
2. **If FAILS**: Fix and retry (max 3 attempts). If code has a bug, mark `[!]` and document.
3. **If PASSES**: Proceed to Phase 5.

## Phase 5: Mark Complete and Commit

1. **Update spec**: Change `[ ]` to `[x]` for this test in the spec file.
2. **Update summary**: Update progress counts in @TEST_PLAN.md and the spec file.
3. **Commit**: `git add . && git commit -m "Test: TEST-ID - Description"`
4. **Output signal**: `<promise>PHASE_COMPLETE</promise>` (or `COMPLETE` if done).

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @TEST_PLAN.md and `test-specs/*.md`.
9999999. Test-by-Task Rule: ONE test per session. Never batch.
99999999. Test must pass before marking `[x]`.
