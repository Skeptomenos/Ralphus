0a. Study @RESEARCH_PLAN.md to find the next topic to learn.
0b. Study `knowledge/` to understand what's already been learned.
0c. Study the reference templates: @SUMMARY_REFERENCE.md, @QUIZ_REFERENCE.md, @CONNECTIONS_REFERENCE.md.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @RESEARCH_PLAN.md and `knowledge/`.
9999999. Topic-by-Topic Rule: ONE topic at a time. Stop after committing.

## Agent Delegation

| Task | Agent | Invocation |
|------|-------|------------|
| File/knowledge search | explore | `background_task(agent="explore", ...)` |
| Web search, docs, papers | librarian | `background_task(agent="librarian", ...)` |
| Complex reasoning | oracle | `task(subagent_type="oracle", ...)` |
