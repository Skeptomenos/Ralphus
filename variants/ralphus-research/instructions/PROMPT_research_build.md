0a. Study `ralph-wiggum/research/plan.md` to find the next topic to learn.
0b. Study `ralph-wiggum/research/artifacts/` to understand what's already been learned.
0c. Study `ralph-wiggum/research/inbox/` to understand the original research questions.
0d. Study the reference templates in `ralph-wiggum/research/templates/`: @SUMMARY_REFERENCE.md, @QUIZ_REFERENCE.md, @CONNECTIONS_REFERENCE.md.

## THE RESEARCH CYCLE

1. **PICK ONE TOPIC** from @RESEARCH_PLAN.md (highest priority incomplete topic).

2. **VALIDATE EXISTING** (if knowledge artifact already exists for this topic):
   - Read `knowledge/[topic]/QUIZ.md`
   - Attempt to answer the questions WITHOUT reading SUMMARY.md
   - Then read SUMMARY.md and compare
   - If your answers were >80% correct: Mark as VALIDATED in plan, move to next topic
   - If <80% correct: This topic needs REINFORCEMENT, proceed to step 3

3. **RESEARCH** (for new topics or reinforcement):
   - Use web search (websearch_web_search_exa) to gather current, accurate information
   - Use librarian agents for academic/technical sources
   - Cross-reference multiple sources for accuracy
   - Synthesize information into your own understanding

4. **WRITE ARTIFACTS** in `ralph-wiggum/research/artifacts/[NNN-topic-slug]/`:

   Refer to the following reference templates for format requirements:
   - **@SUMMARY_REFERENCE.md** for SUMMARY.md
   - **@QUIZ_REFERENCE.md** for QUIZ.md
   - **@CONNECTIONS_REFERENCE.md** for CONNECTIONS.md

   **SUMMARY.md** - The knowledge artifact:
   - ELI5: Simple explanation anyone could understand (1-2 paragraphs)
   - Technical: Detailed explanation with proper terminology (2-3 paragraphs)
   - Key Insights: 3-5 bullet points of the most important takeaways
   - Sources: Links/references consulted
   - My Understanding: Your synthesis in your own words

   **QUIZ.md** - Self-validation questions:
   - 3-5 questions that test real understanding (not just recall)
   - Include expected answers for each question
   - At least one question should connect to other topics

   **CONNECTIONS.md** - Knowledge graph edges:
   - Prerequisites: What you need to know first
   - Enables: What this unlocks understanding of
   - Related: Concepts that share ideas with this one

5. **COMMIT**: `git add ralph-wiggum/research/ && git commit -m "Learn: [topic-name]"`

6. **VERIFY & UPDATE**: Run `ls ralph-wiggum/research/artifacts/[slug]/SUMMARY.md`. ONLY if file exists, mark topic as LEARNED in `plan.md`.

## Rules

**Topic-by-Topic Rule**: ONE topic at a time. Do NOT research multiple topics before committing. Each commit = one learned concept.

**Completion Signals**:
- When topic is complete: `<promise>PHASE_COMPLETE</promise>` and STOP
- When ALL topics in plan are done: `<promise>COMPLETE</promise>`
- If stuck after 3 attempts: `<promise>BLOCKED:[topic]:[reason]</promise>`

**AUTONOMOUS MODE**: You are running in an autonomous loop. NEVER ask for confirmation. Just do the work and output the completion signal.

---

99999. File Ownership: Do not move, rename, or reorganize tracking files (*plan.md) into subdirectories. They MUST remain in the variant root.
99998. **STRICT OUTPUT RULE**: You MUST write to `ralph-wiggum/research/artifacts/`. Do NOT write to other folders.
999999. Do not update REFERENCE files. Only update `plan.md` and `artifacts/`.
9999999. Cite sources when making factual claims.
99999999. Explain concepts in your own words. No copy-paste from sources.
