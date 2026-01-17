# Ralph Loop Learnings

> Research-backed patterns for building autonomous coding loops.  
> Applicable to all Ralphus variants and future loop implementations.

---

## 1. Core Loop Architecture

### The Ralph Wiggum Technique

Named by Geoffrey Huntley, the core insight is: **"Ralph is a Bash loop."**

```
┌──────────────────────────────────────────────────────┐
│                   Ralph Loop (outer)                 │
│  ┌────────────────────────────────────────────────┐  │
│  │  AI SDK Tool Loop (inner)                      │  │
│  │  LLM ↔ tools ↔ LLM ↔ tools ... until done      │  │
│  └────────────────────────────────────────────────┘  │
│                         ↓                            │
│  verifyCompletion: "Is the TASK actually complete?"  │
│                         ↓                            │
│       No? → Inject feedback → Run another iteration  │
│       Yes? → Return final result                     │
└──────────────────────────────────────────────────────┘
```

**Key Insight**: Standard AI tool loops stop when the model finishes tool calls. Ralph wraps this in an **outer verification loop** that continues until the task is actually verified as complete.

### Why This Works

| Problem | Ralph Solution |
|---------|----------------|
| No verification of task completion | `verifyCompletion` callback checks actual success |
| Stops on first failure | Retries with feedback from previous attempts |
| No learning from errors | Context carries forward with reasons for failures |
| Cannot handle multi-step tasks | Iterations continue until complex work is complete |
| Context overflow on long tasks | Auto-summarization when approaching token limits |

---

## 2. Multi-Agent Patterns

### Three-Agent Architecture (Vercel Labs)

The most robust pattern uses specialized agents with different permissions:

| Agent | Role | Environment | Access |
|-------|------|-------------|--------|
| **Interviewer/Planner** | Explore codebase, create task plan | Read-only local | Cannot modify |
| **Executor/Coder** | Implement changes | Isolated sandbox | Full access |
| **Judge/Reviewer** | Verify completion, approve/reject | Read-only sandbox | Cannot modify |

**Why Separate Agents?**
- **Safety**: Judge can't accidentally modify code it's reviewing
- **Focus**: Each agent has a single responsibility
- **Verification**: Independent verification prevents self-approval

### Multi-Agent for Code Review (CodeAgent Paper)

From EMNLP 2024, the CodeAgent system uses:

1. **Task-Specific Agents**: Separate agents for security, style, correctness
2. **QA-Checker Supervisor**: Ensures all agents address the initial question
3. **Communication Protocol**: Agents share findings through structured messages

**Key Insight**: A supervisory agent prevents individual agents from going off-track.

---

## 3. Stop Conditions

### Essential Safety Limits

Every loop MUST have at least one stop condition:

```bash
# Iteration limit
stopWhen: iterationCountIs(50)

# Token budget
stopWhen: tokenCountIs(100_000)

# Cost limit
stopWhen: costIs(5.00)

# Combined (any triggers stop)
stopWhen: [iterationCountIs(50), tokenCountIs(100_000), costIs(5.00)]
```

### Ralphus Implementation

```bash
# Current pattern in loop.sh
if [ "$MAX_ITERATIONS" -gt 0 ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
    echo "Reached max iterations: $MAX_ITERATIONS"
    break
fi
```

**Future Enhancement**: Add token/cost tracking via OpenCode output parsing.

---

## 4. Verification Callbacks

### The Core Pattern

```typescript
verifyCompletion: async ({ result, iteration, allResults, originalPrompt }) => ({
  complete: boolean,     // Is the task done?
  reason?: string,       // Feedback if not complete, explanation if complete
})
```

The `reason` string is **injected into the next iteration**, guiding the agent on what still needs work.

### Ralphus Promise Signals

| Signal | Meaning | Loop Behavior |
|--------|---------|---------------|
| `<promise>PLAN_COMPLETE</promise>` | Planning phase done | Exit 0, run build |
| `<promise>PHASE_COMPLETE</promise>` | One task/item done | Continue loop |
| `<promise>COMPLETE</promise>` | All tasks done | Exit 0 |
| `<promise>APPROVED</promise>` | Review passed (reviewer) | Exit 0 |
| `<promise>BLOCKED:[task]:[reason]</promise>` | Stuck, needs human | Exit 1 |

### Backpressure Through Tests

**Key Insight**: Failing tests are the primary verification mechanism.

- Tests provide objective, repeatable verification
- Failed tests give specific feedback for next iteration
- Passing tests confirm task completion

---

## 5. Context Management

### The 180k Token Problem

Long-running tasks accumulate context. Solutions:

1. **Auto-Summarization**: When approaching limits (e.g., 180k tokens), summarize older iterations
2. **Change Log Tracking**: Maintain a structured log of what changed, not full conversation
3. **Token Budgeting**: Reserve tokens for system prompt + tools + current iteration

### Ralphus Pattern: Fresh Context Per Iteration

Current approach: Each iteration starts fresh, using the tracking file (*_PLAN.md) as the only state.

**Advantages**:
- No context accumulation
- Predictable token usage
- Forces atomic, complete tasks

**Trade-off**: Agent must re-orient each iteration (mitigated by detailed prompts).

---

## 6. Task Granularity

### The Atomic Task Rule

From research and practice:

> Each task must be a **complete logic unit** implementable in one continuous session (~30 mins).

**Good Task Examples**:
- "Implement POST /login with tests and validation"
- "Add user authentication middleware"
- "Fix N+1 query in getUserPosts"

**Bad Task Examples**:
- "Add types" (too vague)
- "Refactor entire codebase" (too large)
- "Implement user system" (too broad)

### Task Breakdown Heuristics

| Scope | Max Files | Max Lines Changed |
|-------|-----------|-------------------|
| Atomic (ideal) | 1-3 | <200 |
| Small | 3-5 | <500 |
| Medium (split this) | 5-10 | <1000 |
| Large (must split) | 10+ | 1000+ |

---

## 7. Error Recovery

### The 3-Attempt Rule

```
If stuck after 3 attempts on same task:
1. Document the issue in tracking file
2. Move to next task
3. Output BLOCKED signal if critical
```

### Error Categories

| Category | Recovery |
|----------|----------|
| Test failure | Fix code, retry |
| Syntax error | Fix immediately, retry |
| Missing dependency | Add to plan, continue |
| External service down | Document, skip for now |
| Unclear requirements | Consult Oracle, document assumption |

---

## 8. Agent Delegation Patterns

### When to Use Subagents

| Task Type | Agent | Rationale |
|-----------|-------|-----------|
| Codebase search | `explore` | Fast, parallel, low cost |
| Doc/API lookup | `librarian` | Specialized for external knowledge |
| Complex reasoning | `oracle` | Higher-capability model |
| Security analysis | `oracle` | Needs careful analysis |
| Frontend UI | `frontend-ui-ux-engineer` | Specialized knowledge |

### Parallel vs Sequential

- **Parallel**: Independent searches, file reads, exploration
- **Sequential**: Dependent operations (write → build → test → commit)

---

## 9. Reviewer-Specific Patterns

### Priority-Based Review Order

| Priority | Category | Why First |
|----------|----------|-----------|
| P0 | Security, Auth, Payments | Highest risk |
| P1 | Core Logic, APIs | Business impact |
| P2 | Integration, DB | Data integrity |
| P3 | UI/Presentation | User-facing |
| P4 | Configuration | Build/deploy |

### Constructive Findings

Every finding should include:
1. **What's wrong** (specific location, code snippet)
2. **Why it matters** (impact, risk)
3. **How to fix** (suggested code)
4. **How to verify** (test or check)

### Approval Criteria

Clear, objective criteria for "done":
- [ ] No critical severity findings
- [ ] No high severity findings unaddressed
- [ ] All security concerns documented
- [ ] Code follows project conventions

---

## 10. Lessons from Production

### From Vercel Labs (ralph-loop-agent)

1. **Sandbox isolation**: Run code modifications in isolated environment
2. **GitHub integration**: Auto-create PRs with review findings
3. **Cost tracking**: Monitor and limit spend per iteration

### From CodeAgent (EMNLP 2024)

1. **Supervisory agent**: QA-Checker ensures focus on original question
2. **Multi-language support**: Different review rules per language
3. **Structured output**: JSON/structured responses for tooling integration

### From crewAI Implementations

1. **Role clarity**: Each agent needs clear role, goal, backstory
2. **Tool specificity**: Custom tools for specific tasks (GitHub API, Notion, etc.)
3. **Sequential vs hierarchical**: Choose based on task dependencies

---

## 11. Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| No stop conditions | Infinite loops, cost explosion | Always set max iterations + cost limit |
| Self-verification | Agent approves its own work | Separate judge agent or external tests |
| Massive tasks | Context overflow, incomplete work | Atomic task breakdown |
| Swallowed errors | Silent failures accumulate | Document all failures in tracking file |
| Hardcoded paths | Breaks in different projects | Use environment variables and detection |
| No archiving | Lost work on branch switch | Archive tracking files on branch change |

---

## 12. Future Enhancements

### For All Variants

- [ ] Token/cost tracking in loop.sh
- [ ] Structured JSON output parsing
- [ ] Webhook notifications on completion/blocked
- [ ] Integration with issue trackers

### For Ralphus Reviewer

- [ ] GitHub PR comment integration
- [ ] Diff-aware review (highlight changed lines)
- [ ] Security-focused mode (P0 only)
- [ ] Incremental review (only new changes since last review)

---

## References

1. **vercel-labs/ralph-loop-agent** - https://github.com/vercel-labs/ralph-loop-agent
2. **CodeAgent Paper (EMNLP 2024)** - https://aclanthology.org/2024.emnlp-main.632/
3. **crewAI Framework** - https://github.com/joaomdmoura/crewAI
4. **Ionio Code Review Agent** - https://github.com/Ionio-io/LLM-agent-for-code-reviews
