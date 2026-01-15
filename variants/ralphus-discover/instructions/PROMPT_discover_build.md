0a. Study @DISCOVERY_PLAN.md to find the next unanswered question.
0b. Study `discoveries/` to understand what's already been discovered.
0c. Study the attached templates for output format.

---

# DISCOVERY PHASE: Answer One Question

You are systematically discovering how this codebase works.

## Your Task

1. **Pick the first unchecked question** from DISCOVERY_PLAN.md
   - Work in order (Architecture → Patterns → Conventions → Data Flow → Tricks → Follow-ups)
   - Skip questions already marked `[x]`

2. **Investigate deeply** using all available tools:
   - Use explore agents to search for relevant code
   - Read key files thoroughly
   - Trace through call chains if needed
   - Look at tests for usage examples
   - Check git history for context on decisions

3. **Create a discovery file** in `discoveries/`:
   - Filename: `{NNN}-{slug}.md` (e.g., `001-entry-points.md`)
   - Use the DISCOVERY.md template format
   - Include concrete evidence (file paths, code snippets)
   - Rate your confidence (High/Medium/Low)

4. **Generate follow-up questions** (0-2 per discovery):
   - What new questions emerged while investigating?
   - Add them to the "Follow-ups" section in DISCOVERY_PLAN.md
   - Only add questions that will yield actionable insights

5. **Update DISCOVERY_PLAN.md**:
   - Mark the question `[x]` complete
   - Add entry to the Discoveries Log table
   - Update the Summary counts

6. **Commit the discovery**:
   ```bash
   git add discoveries/ DISCOVERY_PLAN.md
   git commit -m "Discover: {brief description of what was learned}"
   ```

## Discovery Quality Checklist

Before committing, verify:
- [ ] Answer is specific and evidence-based (not speculation)
- [ ] Key files are listed with explanations
- [ ] Implications section helps future developers
- [ ] Follow-up questions (if any) are actionable
- [ ] Confidence level is honest

## Exhaustion Detection

Check after each discovery:
- Are there remaining unchecked questions? → Continue
- Have 3 consecutive iterations produced no follow-up questions? → Consider synthesis
- All questions answered AND no follow-ups? → Proceed to synthesis

## Synthesis Phase (When Exhausted)

When all questions are answered:

1. Create `CODEBASE_UNDERSTANDING.md` by synthesizing all discoveries
2. Create `PATTERNS.md` — catalog of identified patterns
3. Create `CONVENTIONS.md` — documented conventions
4. Create `GOTCHAS.md` — tricks, quirks, and tribal knowledge

```bash
git add CODEBASE_UNDERSTANDING.md PATTERNS.md CONVENTIONS.md GOTCHAS.md
git commit -m "Synthesize: Complete codebase understanding"
```

Then output:
```
<promise>COMPLETE</promise>
```

## Completion Signals

After each discovery iteration:
```
<promise>PHASE_COMPLETE</promise>
```

When all discoveries complete and synthesized:
```
<promise>COMPLETE</promise>
```

If stuck for 15+ minutes on one question:
```
<promise>BLOCKED:[question]:[reason]</promise>
```

---

**Task-by-Task Rule**: ONE question per session. Do NOT start the next question. The loop restarts you with fresh context.

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation or approval. Just do the work and output the completion signal when done.
