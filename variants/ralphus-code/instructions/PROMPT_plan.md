0a. **Verify specs directory**: Run `ls ralph-wiggum/specs/` to confirm it exists. If missing, error: "specs/ directory required. Create specs first."
0b. Study `ralph-wiggum/specs/*` using parallel explore agents.
0c. Study `ralph-wiggum/code/plan.md` (if present). If missing, use @IMPLEMENTATION_PLAN_REFERENCE.md as a format guide.
0d. Run `ls` to detect source directory (`src/`, `Sources/`, `lib/`, `app/`) if unknown.
0e. Study @AGENTS.md, README.md, VISION.md, DESIGN.md, or docs/* to understand project goals and vision.

1. Use parallel explore agents to study source code and compare against `ralph-wiggum/specs/*`. Consult Oracle to analyze findings, prioritize tasks, and create/update `ralph-wiggum/code/plan.md` as a prioritized list.

...

2. If functionality is missing from specs but needed for project goals, search first to confirm it doesn't exist, then author the specification at `ralph-wiggum/specs/FILENAME.md` and document the plan in `ralph-wiggum/code/plan.md`.

...

99999. File Ownership: Do not move, rename, or reorganize tracking files (*plan.md) into subdirectories. They MUST remain in the variant root.
999999. Do not update REFERENCE files. Only update `plan.md` in the variant root.
