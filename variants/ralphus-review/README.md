# Ralphus Reviewer

Autonomous code review from PR diffs, uncommitted changes, or full codebase.

## How It Works

1. **Plan mode** analyzes scope and creates `REVIEW_PLAN.md` with prioritized items
2. **Review mode** reviews one file per iteration, documents findings in `reviews/`
3. Loop continues until all items reviewed or `APPROVED`/`COMPLETE`

## Quick Start

```bash
# From your project directory
ralphus review plan pr     # Plan review for current PR
ralphus review             # Execute the review

# Or with direct invocation
./ralphus/ralphus-reviewer/scripts/loop.sh plan pr
./ralphus/ralphus-reviewer/scripts/loop.sh
```

## Review Targets

| Target | Description | Command |
|--------|-------------|---------|
| `pr` | Review changes in current branch vs main | `ralphus review plan pr` |
| `diff` | Review uncommitted changes | `ralphus review plan diff` |
| `files` | Review specific files from `review-targets/` | `ralphus review plan files` |
| `codebase` | Full codebase review (default) | `ralphus review plan` |

## Directory Structure

After running, your project will have:

```
your-project/
├── REVIEW_PLAN.md          # Generated review plan with progress
├── reviews/                # Review findings
│   ├── auth_login_review.md
│   └── payments_checkout_review.md
└── review-targets/         # (Optional) For 'files' mode
    └── security-audit.md   # List of files to review
```

## Usage Examples

```bash
# Plan and execute PR review
ralphus review plan pr
ralphus review

# Review with iteration limit
ralphus review 10

# Ultrawork mode (aggressive)
ralphus review ulw

# Plan-only (no review execution)
ralphus review plan pr 1
```

## Completion Signals

| Signal | Meaning |
|--------|---------|
| `<promise>PLAN_COMPLETE</promise>` | Planning done, run review mode |
| `<promise>PHASE_COMPLETE</promise>` | One file reviewed, loop continues |
| `<promise>APPROVED</promise>` | All reviewed, no critical/high findings |
| `<promise>COMPLETE</promise>` | All reviewed, findings documented |
| `<promise>BLOCKED:[file]:[reason]</promise>` | Stuck, needs human help |

## Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| **Critical** | Security vulnerability, data loss risk | Block merge |
| **High** | Bug, logic error, significant issue | Fix before merge |
| **Medium** | Code smell, suboptimal approach | Should fix |
| **Low** | Style, minor improvement | Nice to have |
| **Info** | Suggestion, question | No action required |

## Review Categories

Reviews check files against these categories (in priority order):

1. **Security**: Input validation, injection, auth, secrets
2. **Correctness**: Logic, edge cases, error handling, types
3. **Performance**: Queries, algorithms, resources
4. **Maintainability**: Style, structure, cleanliness
5. **Testing**: Coverage, quality

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RALPH_AGENT` | `Sisyphus` | OpenCode agent to use |
| `OPENCODE_BIN` | `opencode` | Path to OpenCode binary |

## Integration with CI

```yaml
# .github/workflows/review.yml
name: AI Code Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for diff
      
      - name: Run Ralphus Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          ralphus review plan pr 1
          ralphus review 5  # Max 5 iterations
      
      - name: Upload Review Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: review-findings
          path: reviews/
```

## Tips

- **Start with PR mode**: Review only what changed, not the entire codebase
- **Use iteration limits**: Prevent runaway loops with `ralphus review 10`
- **Check reviews/**: Findings are documented with suggested fixes
- **Prioritize**: Critical and High findings should block merge
