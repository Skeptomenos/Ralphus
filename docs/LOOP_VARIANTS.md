# Ralphus Loop Variants: A Concept Paper

> *"The boulder doesn't care what you're pushing it toward."*

## Abstract

Ralphus is not just a coding loop—it's a **general-purpose iterative refinement engine**. The core pattern (queue → execute → generate follow-ups → repeat until exhaustion) applies far beyond software development. This paper explores creative applications of the Ralphus loop pattern across domains.

---

## The Universal Pattern

Every Ralphus variant shares the same fundamental structure:

```
┌─────────────────────────────────────────────────────────────────┐
│                    THE UNIVERSAL LOOP                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    ┌──────────┐     ┌──────────┐     ┌──────────┐              │
│    │  Read    │────▶│ Execute  │────▶│  Commit  │              │
│    │  Queue   │     │  Task    │     │  Output  │              │
│    └──────────┘     └──────────┘     └──────────┘              │
│         ▲                │                 │                    │
│         │                │                 │                    │
│         │                ▼                 │                    │
│         │         ┌──────────┐             │                    │
│         │         │ Generate │             │                    │
│         └─────────│ Follow-  │◀────────────┘                    │
│                   │   ups    │                                  │
│                   └──────────┘                                  │
│                                                                 │
│    Loop until: exhaustion condition met                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

| Component | Description |
|-----------|-------------|
| **Queue** | Prioritized list of tasks/questions/items to process |
| **Execute** | Process one item with full context and tools |
| **Output** | Artifact produced (code, docs, analysis, etc.) |
| **Follow-ups** | New items discovered during execution |
| **Exhaustion** | Condition that signals completion |
| **Backpressure** | Feedback mechanism that validates quality |

---

## The Key Insight: Exhaustion Conditions

What makes each variant unique is its **exhaustion condition**—the signal that the loop has done its job:

| Variant | Exhaustion Condition |
|---------|---------------------|
| Coding | All tests pass, all tasks complete |
| Research | No new questions for N iterations |
| Security Audit | All critical paths analyzed |
| Refactoring | Technical debt catalog stabilizes |
| Documentation | All public APIs documented |
| Test Coverage | Target reached OR diminishing returns |
| Migration | Complete dependency graph built |

---

## Variant Catalog

### 1. Deep Research Loop

**Purpose**: Systematically explore and understand a domain by asking questions that generate more questions.

**The Idea**: Start with 5 seed questions. Each iteration answers one question deeply, then adds 0-2 follow-up questions based on what was discovered. The loop exhausts when no new questions emerge for 3 consecutive iterations.

```
QUESTION_QUEUE.md:
- [ ] What is the core abstraction of this codebase?
- [ ] What are the main data flows?
- [ ] Where are the integration points?
- [ ] What patterns does this codebase use?
- [ ] What's the test strategy?

Each iteration:
1. Answer one question deeply
2. Add 0-2 follow-up questions discovered
3. Mark complete when: no new questions generated for 3 iterations
```

**Output**: `CODEBASE_UNDERSTANDING.md` — a living document that grows organically.

**Backpressure**: Self-quiz validation (see Ralphus Research).

> **Technical Note**: These variants are implemented using the modular [shared library pattern](MODULAR_ARCHITECTURE.md).

**Use Cases**:
- Onboarding to a new codebase
- Due diligence on acquisitions
- Understanding competitor products
- Learning new domains

---

### 2. Security Audit Loop

**Purpose**: Systematically discover and document security vulnerabilities.

**The Idea**: Start with common attack vectors. Each iteration investigates one attack surface, documents findings, and adds related areas to check based on discoveries.

```
VULNERABILITY_QUEUE.md:
- [ ] Check authentication boundaries
- [ ] Find SQL/injection vectors
- [ ] Audit secrets handling
- [ ] Review input validation
- [ ] Check dependency vulnerabilities
- [ ] Analyze authorization logic
- [ ] Review session management
- [ ] Check CORS configuration

Each iteration:
1. Investigate one attack surface
2. Document findings with severity (Critical/High/Medium/Low)
3. Add related areas discovered ("found raw SQL in X, check Y and Z")
4. Complete when: all high-severity paths exhausted
```

**Output**: `SECURITY_AUDIT.md` — vulnerability catalog with severity ratings.

**Backpressure**: Severity classification forces prioritization.

**Exhaustion Signals**:
- All Critical/High items addressed
- 3 iterations with only Low/Info findings
- Explicit "audit complete" from security checklist

---

### 3. Refactoring Discovery Loop

**Purpose**: Build a comprehensive technical debt catalog before refactoring.

**The Idea**: Hunt for code smells systematically. Each iteration focuses on one smell type, documents instances, and discovers related smells.

```
SMELL_QUEUE.md:
- [ ] Find god classes (>500 lines)
- [ ] Find duplicated logic
- [ ] Find circular dependencies
- [ ] Find dead code
- [ ] Find inconsistent patterns
- [ ] Find missing abstractions
- [ ] Find leaky abstractions
- [ ] Find primitive obsession

Each iteration:
1. Hunt for one smell type across codebase
2. Document instances with refactoring suggestions
3. Add related smells discovered ("this duplication suggests missing abstraction X")
4. Complete when: technical debt catalog stabilizes (no new smells for 2 iterations)
```

**Output**: `TECH_DEBT_CATALOG.md` — prioritized refactoring roadmap.

**Backpressure**: Impact scoring (effort vs. value).

**Key Insight**: Don't refactor during discovery. Catalog first, then prioritize, then execute.

---

### 4. Documentation Generation Loop

**Purpose**: Systematically document a codebase by discovering what needs documenting.

**The Idea**: Start with obvious documentation targets. Each iteration documents one area and discovers undocumented dependencies.

```
DOC_QUEUE.md:
- [ ] Document public API
- [ ] Document architecture decisions
- [ ] Document deployment process
- [ ] Document data models
- [ ] Document integration points
- [ ] Document error handling patterns
- [ ] Document configuration options

Each iteration:
1. Document one area thoroughly
2. Discover undocumented dependencies ("API uses AuthService, add to queue")
3. Complete when: all public interfaces documented
```

**Output**: `docs/` directory with comprehensive documentation.

**Backpressure**: Coverage metrics (% of public APIs documented).

**Variant**: Can generate different doc types per iteration (README, API docs, architecture diagrams).

---

### 5. Test Coverage Expansion Loop

**Purpose**: Systematically increase test coverage by discovering untested paths.

**The Idea**: Start with obvious coverage gaps. Each iteration writes tests for one area and discovers untested dependencies.

```
COVERAGE_QUEUE.md:
- [ ] Unit tests for core/auth
- [ ] Integration tests for API endpoints
- [ ] Edge cases for payment flow
- [ ] Error handling coverage
- [ ] Boundary condition tests
- [ ] Concurrency tests

Each iteration:
1. Write tests for one area
2. Discover untested paths ("this function calls X which has no tests")
3. Complete when: coverage target reached OR diminishing returns (3 iterations < 1% gain)
```

**Output**: Expanded test suite with coverage report.

**Backpressure**: Coverage percentage (hard metric).

**Key Insight**: Diminishing returns is a valid exhaustion condition. 95% → 96% might not be worth the effort.

---

### 6. Migration Planning Loop

**Purpose**: Build a complete migration plan by discovering all dependencies.

**The Idea**: Start with known migration targets. Each iteration analyzes one aspect and discovers blockers and dependencies.

```
MIGRATION_QUEUE.md:
- [ ] Inventory all usages of deprecated API
- [ ] Map dependencies between modules
- [ ] Identify breaking changes needed
- [ ] Plan migration order
- [ ] Identify rollback strategies
- [ ] Document data migration needs

Each iteration:
1. Analyze one migration aspect
2. Discover blockers ("can't migrate X until Y is done")
3. Build dependency graph
4. Complete when: complete dependency graph with no unknowns
```

**Output**: `MIGRATION_PLAN.md` — ordered migration steps with dependencies.

**Backpressure**: Dependency validation (can't proceed if prerequisites unknown).

---

### 7. Competitive Analysis Loop

**Purpose**: Systematically analyze competitors by asking questions that reveal more questions.

**The Idea**: Start with basic competitive questions. Each iteration researches one aspect and discovers new angles to investigate.

```
COMPETITOR_QUEUE.md:
- [ ] What features does competitor A have?
- [ ] How does their pricing work?
- [ ] What's their tech stack?
- [ ] What do users complain about?
- [ ] What's their go-to-market strategy?
- [ ] How do they handle [specific use case]?

Each iteration:
1. Research one aspect (web search, docs, reviews)
2. Add follow-up questions ("they have feature X, how does it work?")
3. Complete when: comprehensive comparison matrix built
```

**Output**: `COMPETITIVE_ANALYSIS.md` — feature matrix with strategic insights.

**Backpressure**: Completeness of comparison matrix.

**Note**: This is a non-code application of the Ralphus pattern!

---

### 8. Bug Archaeology Loop

**Purpose**: Investigate mysterious bugs by tracing through history and code.

**The Idea**: Start with the bug symptom. Each iteration investigates one angle and discovers related mysteries.

```
BUG_QUEUE.md:
- [ ] Why does flaky test X fail?
- [ ] What caused production incident Y?
- [ ] Why is this workaround here?
- [ ] When did this behavior change?
- [ ] Who added this and why?

Each iteration:
1. Investigate one mystery
2. Trace through git history, logs, code
3. Add related mysteries discovered
4. Complete when: root cause identified and documented
```

**Output**: `ROOT_CAUSE_ANALYSIS.md` — detailed investigation with timeline.

**Backpressure**: Reproducibility (can you trigger the bug reliably?).

**Tools**: `git log`, `git blame`, `git bisect`, log analysis.

---

### 9. API Design Review Loop

**Purpose**: Systematically review and improve API design.

**The Idea**: Start with API design principles. Each iteration checks one principle and discovers violations.

```
API_REVIEW_QUEUE.md:
- [ ] Check consistency of naming conventions
- [ ] Verify RESTful resource modeling
- [ ] Review error response formats
- [ ] Check pagination patterns
- [ ] Verify authentication/authorization
- [ ] Review rate limiting
- [ ] Check versioning strategy

Each iteration:
1. Review one design aspect
2. Document violations with recommendations
3. Discover related issues ("inconsistent naming suggests missing style guide")
4. Complete when: all principles reviewed, violations documented
```

**Output**: `API_REVIEW.md` — design issues with recommendations.

**Backpressure**: Severity classification of violations.

---

### 10. Performance Profiling Loop

**Purpose**: Systematically identify and document performance bottlenecks.

**The Idea**: Start with known slow paths. Each iteration profiles one area and discovers related bottlenecks.

```
PERF_QUEUE.md:
- [ ] Profile database queries
- [ ] Analyze API response times
- [ ] Check memory usage patterns
- [ ] Review caching effectiveness
- [ ] Identify N+1 queries
- [ ] Check bundle sizes (frontend)

Each iteration:
1. Profile one area with metrics
2. Document bottlenecks with severity
3. Discover related issues ("slow query causes cascade in X")
4. Complete when: all critical paths profiled, top 10 bottlenecks identified
```

**Output**: `PERFORMANCE_REPORT.md` — bottlenecks ranked by impact.

**Backpressure**: Measurable metrics (response time, memory, CPU).

---

## Implementation: Generic Loop Configuration

To make Ralphus truly generic, we can introduce a `LOOP_CONFIG.md`:

```markdown
# Loop Configuration

## Variant
type: research | audit | refactor | docs | test | migration | custom

## Queue
file: QUESTION_QUEUE.md
format: markdown-checklist

## Output
directory: findings/
artifact_template: |
  # {topic}
  ## Summary
  ## Details
  ## Follow-ups

## Exhaustion Conditions
- no_new_items_for: 3
- max_iterations: 50
- coverage_target: 0.90
- manual_signal: "EXHAUSTED"

## Backpressure
mechanism: self-quiz | tests | coverage | severity | manual
threshold: 0.80

## Iteration Prompt
Pick the highest priority incomplete item from @{queue_file}.
Execute according to variant rules.
Add follow-up items discovered.
Output completion signal when exhaustion condition met.
```

Then `loop.sh` becomes truly generic:

```bash
#!/bin/bash
set -euo pipefail

CONFIG_FILE="${1:-LOOP_CONFIG.md}"
MAX_ITERATIONS="${2:-50}"

# Parse config and run appropriate prompt
VARIANT=$(grep "^type:" "$CONFIG_FILE" | cut -d: -f2 | tr -d ' ')
PROMPT_FILE="PROMPT_${VARIANT}.md"

for ((i=1; i<=MAX_ITERATIONS; i++)); do
    echo "=== Iteration $i ==="
    opencode run --agent Sisyphus -f "$PROMPT_FILE" "Execute iteration $i"
    
    # Check for exhaustion signals
    if grep -q "EXHAUSTED\|COMPLETE" "$OUTPUT_FILE" 2>/dev/null; then
        echo "Loop exhausted after $i iterations"
        exit 0
    fi
done
```

---

## Design Principles

### 1. Atomic Iterations

Each iteration should do ONE thing completely. Don't batch. Don't parallelize across items. One item → one commit → context clear.

### 2. Self-Generating Queues

The magic is in follow-up generation. A good iteration doesn't just complete a task—it discovers new tasks. This is how the loop explores unknown territory.

### 3. Clear Exhaustion

Every variant needs a crisp exhaustion condition. Without it, the loop runs forever (or until your API budget dies).

### 4. Meaningful Backpressure

Backpressure prevents garbage accumulation. In coding, it's tests. In research, it's quizzes. In audits, it's severity ratings. Find your backpressure.

### 5. Commit Everything

Every iteration should produce a commit. This creates:
- Audit trail
- Recovery points
- Learning journal (for humans reviewing later)

---

## Anti-Patterns

| Don't | Why | Do Instead |
|-------|-----|------------|
| Batch multiple items per iteration | Loses atomicity, harder to debug | One item per iteration |
| Skip follow-up generation | Loop can't explore | Always ask "what did I discover?" |
| Vague exhaustion conditions | Loop never ends | Define crisp, measurable conditions |
| No backpressure | Garbage accumulates | Add validation mechanism |
| Skip commits | No recovery, no audit trail | Commit every iteration |

---

## Future Directions

### Parallel Variant Execution

Run multiple loop variants simultaneously on the same codebase:
- Security audit loop
- Documentation loop
- Test coverage loop

Each operates independently, commits to separate branches, merges when complete.

### Cross-Variant Dependencies

Some variants naturally feed into others:
- Research loop → informs → Refactoring loop
- Security audit → informs → Test coverage loop
- Bug archaeology → informs → Documentation loop

### Human-in-the-Loop Variants

Some variants benefit from human checkpoints:
- Every N iterations, pause for human review
- Human can add items to queue
- Human can adjust exhaustion conditions

---

## Conclusion

The Ralphus loop is a universal pattern for iterative refinement. By identifying the right:
- Queue structure
- Execution logic
- Follow-up generation
- Exhaustion condition
- Backpressure mechanism

...you can apply it to almost any domain that benefits from systematic exploration.

The boulder doesn't care what you're pushing it toward. It just keeps rolling.

---

## Appendix: Quick Reference

| Variant | Queue | Output | Exhaustion | Backpressure |
|---------|-------|--------|------------|--------------|
| Coding | IMPLEMENTATION_PLAN.md | Code + tests | All tests pass | Test results |
| **Test Creation** | TEST_SPECIFICATION.md | Test files | All tests `[x]` | Test passes |
| Research | QUESTION_QUEUE.md | Knowledge artifacts | No new questions | Self-quiz |
| Security | VULNERABILITY_QUEUE.md | Audit report | Critical paths done | Severity |
| Refactoring | SMELL_QUEUE.md | Debt catalog | Catalog stabilizes | Impact score |
| Documentation | DOC_QUEUE.md | docs/ directory | APIs documented | Coverage % |
| Test Coverage | COVERAGE_QUEUE.md | Test suite | Target reached | Coverage % |
| Migration | MIGRATION_QUEUE.md | Migration plan | Graph complete | Dependencies |
| Competitive | COMPETITOR_QUEUE.md | Analysis matrix | Matrix complete | Completeness |
| Bug Archaeology | BUG_QUEUE.md | RCA document | Root cause found | Reproducibility |
| API Review | API_REVIEW_QUEUE.md | Review report | Principles checked | Severity |
| Performance | PERF_QUEUE.md | Perf report | Top N found | Metrics |

---

*"One must imagine Sisyphus documenting his boulder-pushing methodology."*
