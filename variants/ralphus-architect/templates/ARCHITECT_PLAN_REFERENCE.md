<!-- Architect's Scratchpad - Not final output -->

# Architecture Plan

## Input Analysis
- **Source**: `ideas/feature.md` OR `reviews/`
- **Core Goal**: [Goal]

## Discovery Findings
| Component | Existing Pattern | Change Needed |
|-----------|------------------|---------------|
| Auth | JWT in cookies | None |
| DB | Prisma + Postgres | Add column |
| UI | Tailwind | Add `dark:` classes |

## Strategy
1. **Filtering**: Ignore Low/Info findings. Only fix Critical/High/Medium.
2. **Grouping**: Combine duplicate issues (e.g. same import error in 5 files).
3. **Specification**: Create atomic, testable tasks for `ralphus-code`.

## Action Plan
- [ ] Read review file
- [ ] Extract actionable items
- [ ] Append to `specs/review-fixes.md` (if any)
- [ ] Move to `processed/` (handled by script)

## Risk Assessment
- **Breaking Changes**: None expected.
- **Performance**: N/A.
- **Security**: Need to validate input enum.
