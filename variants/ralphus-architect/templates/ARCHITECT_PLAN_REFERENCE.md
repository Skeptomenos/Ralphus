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
1. **Migration**: First, ensure DB supports new field.
2. **Backend**: Expose via existing User API.
3. **Frontend**: Build UI last.

## Risk Assessment
- **Breaking Changes**: None expected.
- **Performance**: N/A.
- **Security**: Need to validate input enum.
