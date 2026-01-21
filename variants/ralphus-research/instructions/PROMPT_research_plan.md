0a. Study `ralph-wiggum/research/inbox/` using parallel explore agents to understand research scope.
0b. Study `ralph-wiggum/research/plan.md` (if present). If missing, use @RESEARCH_PLAN_REFERENCE.md as a format guide.
0c. Study `ralph-wiggum/research/artifacts/` directory to see what has already been learned.
0d. Run `ls` to detect directory structure.

1. Use explore agents and web search (websearch_web_search_exa) to understand the domain. Break each research question into learnable sub-topics:
   - Each topic should be atomic (explainable in 200-500 words)
   - Order by dependencies (what must be understood first?)
   - Start with foundational concepts, build to advanced

2. Create/update `ralph-wiggum/research/plan.md` as a prioritized learning path using the format in @RESEARCH_PLAN_REFERENCE.md:
   - Phase 1: Foundations (prerequisites, basic concepts)
   - Phase 2: Core Concepts (main ideas)
   - Phase 3: Advanced Topics (nuances, edge cases, applications)
   - Phase 4: Synthesis (connections, big picture)

3. For each topic in the plan, define:
   - Learning objective: What should be explainable after learning this?
   - Key questions: 2-3 questions this topic should answer
   - Dependencies: Which topics must be learned first?
   - Connections: How does this relate to other topics?

IMPORTANT: Plan only. Do NOT write knowledge artifacts yet. Do NOT research deeply yet.

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation or approval. Just do the work and output the completion signal when done.

When planning is complete, output `<promise>PHASE_COMPLETE</promise>` and STOP.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*plan.md) into subdirectories. They MUST remain in the variant root.
999999. Do not update REFERENCE files. Only update `plan.md` in the variant root.
