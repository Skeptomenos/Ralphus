# Ultrawork Integration for Ralphus

> *"Just type 'ulw'. Sip your coffee. Your work is done."* — oh-my-opencode

## What is Ultrawork?

**Ultrawork** (or `ulw`) is oh-my-opencode's magic keyword that transforms Sisyphus into a relentless execution machine. When you include `ultrawork` in your prompt, the agent:

1. Fires parallel background agents to map the territory
2. Uses LSP for surgical refactoring
3. Delegates frontend to specialized agents (Gemini 3 Pro)
4. Calls Oracle (GPT 5.2) when stuck
5. **Keeps working until the TODO list is 100% complete**

The key insight: **Ultrawork is designed to complete entire implementation plans in one go.**

---

## The Problem: Ultrawork vs Ralphus Loop

Ralphus operates in an **iterative loop** where context clears after each iteration. This is by design — it prevents context exhaustion and allows the agent to work indefinitely.

Ultrawork, however, is designed for **single-session completion**. It expects to:
- Read the full plan
- Execute everything
- Not stop until done

**These two approaches conflict.** If you give Ultrawork a 50-task IMPLEMENTATION_PLAN.md, it will try to complete all 50 tasks in one session, potentially:
- Exhausting context
- Making mistakes due to context overload
- Never outputting `<promise>COMPLETE</promise>` because there's always more to do

---

## The Solution: Single-Story Focus

To use Ultrawork effectively with Ralphus, **scope each iteration to a single story/feature**.

### Pattern 1: Story-Scoped IMPLEMENTATION_PLAN.md

Instead of one massive plan, create story-specific plans:

```
your-project/
├── IMPLEMENTATION_PLAN.md           # Current story only
├── archive/
│   └── completed/
│       ├── story-001-auth.md
│       └── story-002-dashboard.md
└── backlog/
    ├── story-003-notifications.md
    └── story-004-settings.md
```

Each `IMPLEMENTATION_PLAN.md` contains only the tasks for the current story. When complete, archive it and promote the next story from backlog.

### Pattern 2: Ultrawork-Specific Prompt

Create a `PROMPT_ultrawork.md` that explicitly scopes to one story:

```markdown
# Ultrawork Mode

You are in ULTRAWORK mode. This means:
1. Complete ALL tasks in @IMPLEMENTATION_PLAN.md before stopping
2. Fire parallel agents aggressively
3. Delegate to specialists (Oracle, Frontend, Librarian)
4. Do NOT stop until every task is marked complete

CRITICAL: @IMPLEMENTATION_PLAN.md contains ONLY the current story.
If you see tasks for multiple stories, STOP and ask for clarification.

When ALL tasks are complete:
<promise>COMPLETE</promise>

ulw
```

### Pattern 3: Loop with Ultrawork Bursts

Modify `loop.sh` to support an ultrawork mode:

```bash
./loop.sh ultrawork    # Single iteration with ultrawork enabled
./loop.sh              # Normal iterative mode
```

In ultrawork mode:
- Use `PROMPT_ultrawork.md` instead of `PROMPT_build.md`
- Expect completion in one iteration
- No max iteration limit (ultrawork decides when done)

---

## Implementation Recommendations

### 1. Create PROMPT_ultrawork.md

A specialized prompt that:
- Includes the `ultrawork` keyword
- Explicitly scopes to single-story completion
- Emphasizes parallel agent usage
- Has stricter completion criteria

### 2. Add Story Management to loop.sh

```bash
# Promote next story when current completes
if [[ "$OUTPUT" == *"<promise>COMPLETE</promise>"* ]]; then
    archive_current_story
    promote_next_story
    # Continue loop with new story
fi
```

### 3. Story Validation

Before starting ultrawork mode, validate that IMPLEMENTATION_PLAN.md:
- Contains tasks for only ONE story
- Has a clear "Definition of Done"
- Is reasonably scoped (< 20 tasks recommended)

---

## When to Use Each Mode

| Mode | Use When | Scope |
|------|----------|-------|
| **Normal Loop** | Large projects, ongoing development | Any size plan |
| **Ultrawork** | Single feature, time-boxed sprint | One story only |
| **Plan Mode** | Starting new work, re-prioritizing | Analysis only |

### Ultrawork is Best For:

- ✅ Single feature implementation
- ✅ Bug fix with clear scope
- ✅ Refactoring a specific module
- ✅ Adding tests to existing code
- ✅ Documentation sprint

### Ultrawork is NOT For:

- ❌ Multi-feature releases
- ❌ Exploratory work without clear scope
- ❌ Projects with 50+ tasks
- ❌ Work that requires human review mid-stream

---

## Example: Ultrawork Story Flow

### Step 1: Create Story Plan

```markdown
# IMPLEMENTATION_PLAN.md

## Story: Add User Authentication

### Definition of Done
- [ ] Users can register with email/password
- [ ] Users can login and receive JWT
- [ ] Protected routes require valid JWT
- [ ] Tests pass, no type errors

### Tasks
1. [ ] Create User model with password hashing
2. [ ] Implement /register endpoint
3. [ ] Implement /login endpoint
4. [ ] Add JWT middleware
5. [ ] Protect /api/* routes
6. [ ] Write integration tests
7. [ ] Update API documentation
```

### Step 2: Run Ultrawork

```bash
./loop.sh ultrawork
```

Sisyphus will:
1. Read the plan
2. Fire explore agents to understand existing auth patterns
3. Consult librarian for JWT best practices
4. Implement each task, delegating frontend to specialist
5. Run tests after each implementation
6. Consult Oracle if stuck
7. Output `<promise>COMPLETE</promise>` when all tasks done

### Step 3: Archive and Continue

```bash
# Automatic on completion:
mv IMPLEMENTATION_PLAN.md archive/completed/story-auth-$(date +%Y%m%d).md
cp backlog/story-003-notifications.md IMPLEMENTATION_PLAN.md
```

---

## Configuration

### Enable Ultrawork in oh-my-opencode

Ultrawork is enabled by default in oh-my-opencode. The keyword triggers:
- Aggressive parallel agent spawning
- TODO continuation enforcement (won't quit halfway)
- Comment checker (keeps code clean)
- Automatic specialist delegation

### Customize Agent Models

In `oh-my-opencode.json`:

```json
{
  "agents": {
    "oracle": { "model": "openai/gpt-5.2" },
    "frontend-ui-ux-engineer": { "model": "google/gemini-3-pro" },
    "librarian": { "model": "anthropic/claude-sonnet-4.5" },
    "explore": { "model": "xai/grok-code" }
  }
}
```

---

## Summary

| Concept | Ralphus Loop | Ultrawork |
|---------|--------------|-----------|
| **Scope** | Any size plan | Single story |
| **Iterations** | Many, context clears | One, runs to completion |
| **Completion** | Per-task commits | All-or-nothing |
| **Best for** | Ongoing development | Focused sprints |

**The key to using Ultrawork with Ralphus**: Scope your IMPLEMENTATION_PLAN.md to a single story. Let Ultrawork complete it in one powerful burst. Then loop to the next story.

---

## Future Work

1. **PROMPT_ultrawork.md**: Create dedicated ultrawork prompt
2. **Story management in loop.sh**: Auto-archive and promote stories
3. **Story validation**: Warn if plan has too many tasks for ultrawork
4. **Hybrid mode**: Normal loop with ultrawork bursts for complex tasks

---

*"One must imagine Sisyphus in ultrawork mode. The boulder doesn't just reach the top — it stays there."*
