0a. Study the codebase structure using parallel explore agents. Get a high-level overview before planning.
0b. Study @DISCOVERY_PLAN.md (if present). If missing, use @DISCOVERY_PLAN_REFERENCE.md.
0c. Study the attached @DISCOVERY_PLAN_REFERENCE.md to understand the expected format.

---

# PLANNING PHASE: Generate Discovery Plan

1. **Scan the codebase** to understand project type and structure.

2. **Generate DISCOVERY_PLAN.md**: Use @DISCOVERY_PLAN_REFERENCE.md as your structure guide. 

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @DISCOVERY_PLAN.md.

3. **Customize the plan** based on codebase signals:
   - If you see `docker-compose.yml` → add questions about containerization
   - If you see `migrations/` → add questions about database schema evolution
   - If you see `.github/workflows/` → add questions about CI/CD
   - If you see `tests/` or `__tests__/` → add questions about testing strategy
   - If you see multiple languages → add questions about polyglot architecture

## Question Design Principles

Good discovery questions are:
- **Specific**: "How is authentication implemented?" not "How does security work?"
- **Actionable**: The answer should help someone work in the codebase
- **Observable**: Can be answered by reading code, not speculation
- **Generative**: Likely to reveal follow-up questions

## Output

Create `DISCOVERY_PLAN.md` in the project root with:
1. Summary table (will be updated as discoveries are made)
2. Categorized questions with checkboxes
3. Empty "Follow-ups" section for questions discovered during exploration
4. Empty "Discoveries Log" table

## Commit

```bash
git add DISCOVERY_PLAN.md
git commit -m "Plan: Initialize codebase discovery plan"
```

## Completion Signal

When the discovery plan is complete and committed:

```
<promise>PLAN_COMPLETE</promise>
```

---

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation or approval. NEVER ask "Would you like me to...?" or "Should I proceed?". Just do the work and output the completion signal when done.
