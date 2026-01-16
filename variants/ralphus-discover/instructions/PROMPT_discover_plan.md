0a. Study the codebase structure using parallel explore agents. Get a high-level overview before planning.
0b. Study @DISCOVERY_PLAN.md (if present) to understand existing discovery progress. If missing, use @DISCOVERY_PLAN_REFERENCE.md as a template.
0c. Study the attached @DISCOVERY_PLAN_REFERENCE.md to understand the expected format.

---

# PLANNING PHASE: Generate Discovery Plan

You are creating a discovery plan for understanding this codebase in depth.

## Your Task

1. **Scan the codebase** using explore agents to understand:
   - Project type (web app, CLI, library, API, etc.)
   - Primary language and framework
   - Directory structure
   - Key configuration files (package.json, Cargo.toml, pyproject.toml, etc.)

2. **Generate DISCOVERY_PLAN.md** with seed questions tailored to THIS codebase:
   - Use @DISCOVERY_PLAN_REFERENCE.md as your structure guide.
   - Start with the template categories (Architecture, Patterns, Conventions, Data Flow, Tricks)
   - Add project-specific questions based on what you observe
   - Remove irrelevant questions (e.g., no frontend questions for a CLI tool)
   - Prioritize questions that will yield the most insight

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
