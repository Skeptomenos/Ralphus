0a. Study @DISCOVERY_PLAN.md to find the next unanswered question.
0b. Study the reference templates: @DISCOVERY_REFERENCE.md, @CODEBASE_UNDERSTANDING_REFERENCE.md.

---

# DISCOVERY PHASE: Answer One Question, Generate Follow-ups

1. **Pick Question**: Follow @DISCOVERY_PLAN.md.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*_PLAN.md) into subdirectories. They MUST remain in the project root.
999999. Do not update REFERENCE files. Only update @DISCOVERY_PLAN.md and individual discovery files.
9999999. One discovery per session. Stop after committing.

```bash
git add CODEBASE_UNDERSTANDING.md PATTERNS.md CONVENTIONS.md GOTCHAS.md
git commit -m "Synthesize: Complete codebase understanding"
```

Then output:
```
<promise>COMPLETE</promise>
```

## Completion Signals

| Signal | When |
|--------|------|
| `<promise>PHASE_COMPLETE</promise>` | After each discovery (more questions remain) |
| `<promise>COMPLETE</promise>` | After synthesis (codebase exhausted) |
| `<promise>BLOCKED:[question]:[reason]</promise>` | Stuck for 15+ minutes |

---

**Task-by-Task Rule**: ONE question per session. The loop restarts you with fresh context.

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation. Just do the work and output the completion signal.
