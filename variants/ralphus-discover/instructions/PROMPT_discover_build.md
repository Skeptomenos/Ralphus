0a. Study @DISCOVERY_PLAN.md to find the next unanswered question.
0b. Study `discoveries/` to understand what's already been discovered.
0c. Study the attached reference templates for format requirements:
   - **@DISCOVERY_REFERENCE.md** for individual discoveries
   - **@CODEBASE_UNDERSTANDING_REFERENCE.md** for synthesis overview

---

# DISCOVERY PHASE: Answer One Question, Generate Follow-ups

You are systematically discovering how this codebase works. The key mechanic is **follow-up generation** — each discovery should reveal new questions that dig deeper.

## Core Loop Mechanic

```
Answer Question → Generate 1-2 Follow-ups → Loop Continues
Answer Question → Generate 0 Follow-ups → Exhaustion Counter +1
3 Consecutive Zero Follow-ups → Codebase Exhausted → Synthesize
```

## Your Task

### 1. Pick the Next Question

From DISCOVERY_PLAN.md, pick the **first unchecked question**:
- Check "Follow-ups" section FIRST (depth-first exploration)
- Then check seed questions by phase (Architecture → Patterns → Conventions → Data Flow → Tricks)
- Skip questions marked `[x]`

### 2. Investigate Deeply

Use all available tools to answer thoroughly:
- **Explore agents**: Search for relevant code patterns
- **File reading**: Read key files completely, not just snippets
- **Call tracing**: Follow function calls to understand flow
- **Test inspection**: Tests reveal intended usage
- **Git history**: `git log -p --follow <file>` for context on decisions

**Depth over breadth**: It's better to deeply understand one thing than superficially cover many.

### 3. Create Discovery File

Create `discoveries/{NNN}-{slug}.md` using the format in @DISCOVERY_REFERENCE.md:

```markdown
# Discovery: {Question}

> Category: {Phase}
> Discovered: {DATE}
> Confidence: High | Medium | Low

## Answer
[Direct, evidence-based answer in 1-3 paragraphs]

## Evidence
[File paths, code snippets, specific examples]

## Implications
[What this means for working in this codebase]

## Follow-up Questions
- [ ] {New question that digs deeper}
- [ ] {Another question if applicable}
```

### 4. Generate Follow-up Questions (CRITICAL)

This is the **most important step**. Ask yourself:

> "What new questions emerged while investigating this?"

Good follow-ups:
- Dig deeper into something surprising you found
- Explore connections to other parts of the codebase
- Investigate edge cases or error paths you noticed
- Question assumptions that might not hold

Examples:
- "How does X handle the edge case when Y is null?" (discovered Y can be null)
- "Why does module A depend on module B?" (discovered unexpected dependency)
- "What happens when the cache expires?" (discovered caching layer)

**Generate 1-2 follow-ups per discovery.** Only generate 0 if you genuinely found nothing new to explore.

### 5. Update DISCOVERY_PLAN.md

1. Mark the question `[x]` complete
2. Add follow-up questions to the "Follow-ups" section with `- [ ]`
3. Update the Discoveries Log table
4. Update the Summary counts
5. **Track exhaustion**: Note in the log if this discovery generated 0 follow-ups

### 6. Commit

```bash
git add discoveries/ DISCOVERY_PLAN.md
git commit -m "Discover: {brief description}"
```

## Exhaustion Detection

After updating DISCOVERY_PLAN.md, check:

| Condition | Action |
|-----------|--------|
| Unchecked questions remain | Output `PHASE_COMPLETE`, loop continues |
| 3 consecutive discoveries with 0 follow-ups | Codebase likely exhausted, proceed to synthesis |
| All questions answered AND no follow-ups | Proceed to synthesis |

**How to track**: The Discoveries Log should note follow-up count. If the last 3 entries show "0 follow-ups", trigger synthesis.

## Synthesis Phase

When exhausted, create summary documents using @CODEBASE_UNDERSTANDING_REFERENCE.md as a guide:

1. **CODEBASE_UNDERSTANDING.md** — Synthesize all discoveries into coherent overview
2. **PATTERNS.md** — Catalog of identified patterns with examples
3. **CONVENTIONS.md** — Documented conventions and style rules
4. **GOTCHAS.md** — Tricks, quirks, workarounds, and tribal knowledge

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
