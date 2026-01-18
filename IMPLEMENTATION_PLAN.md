# Modular Loop Architecture - Implementation Plan

> **Spec**: `specs/modular-loop.md`
> **Goal**: Refactor 7 variant loop scripts into shared library + thin wrappers
> **Target**: 1,154 lines -> ~450 lines (61% reduction)

---

## Phase 1: Create Shared Library

- [x] 1.1 Create `lib/` directory in ralphus root
- [x] 1.2 Create `lib/loop_core.sh` with shebang, header comment, and `set -euo pipefail`
- [ ] 1.3 Implement `init_ralphus()`: Parse SCRIPT_DIR, VARIANT_DIR from caller; set WORKING_DIR from RALPHUS_WORKING_DIR or pwd; set AGENT from RALPH_AGENT (default: Sisyphus); set OPENCODE from OPENCODE_BIN (default: opencode); initialize ULTRAWORK=0, MODE="build", MAX_ITERATIONS=0, CUSTOM_PROMPT=""
- [ ] 1.4 Implement `parse_common_args()`: Handle plan, ulw/ultrawork, numeric (max iterations), help, custom strings/files; store results in global variables
- [ ] 1.5 Implement `show_header()`: Print variant name, mode, agent, current branch; print ultrawork and max_iterations if set
- [ ] 1.6 Implement `validate_common()`: Check PROMPT_FILE exists; check TEMPLATES_DIR exists
- [ ] 1.7 Implement `archive_on_branch_change()`: Read LAST_BRANCH_FILE, compare to CURRENT_BRANCH; if different, create archive dir and copy ARCHIVE_FILES; write CURRENT_BRANCH to LAST_BRANCH_FILE
- [ ] 1.8 Implement `setup_shutdown_handler()`: Set SHUTDOWN=0; trap INT TERM to set SHUTDOWN=1 with message
- [ ] 1.9 Implement `check_shutdown()`: If SHUTDOWN=1, echo and exit 0
- [ ] 1.10 Implement `check_max_iterations()`: If MAX_ITERATIONS > 0 and ITERATION >= MAX_ITERATIONS, return 1
- [ ] 1.11 Implement `build_base_message()`: Construct message with optional ulw suffix; append CUSTOM_PROMPT if set
- [ ] 1.12 Implement `run_opencode()`: Accept template files as arguments; execute $OPENCODE run with --agent, -f flags, capture output
- [ ] 1.13 Implement `check_signals()`: Check for PLAN_COMPLETE, PHASE_COMPLETE, COMPLETE, BLOCKED, APPROVED; return appropriate exit codes
- [ ] 1.14 Implement `git_push()`: Push to origin with retry and -u fallback
- [ ] 1.15 Implement `run_loop()`: Main entry point calling init, parse, validate, loop; call variant hooks: validate_variant, get_templates, build_message, post_iteration
- [ ] 1.16 Add default no-op implementations for optional hooks (validate_variant, get_archive_files, build_message, post_iteration)

---

## Phase 2: Create Variant Configs

- [ ] 2.1 Create `variants/ralphus-code/config.sh` with: VARIANT_NAME="code", TRACKING_FILE="IMPLEMENTATION_PLAN.md", LAST_BRANCH_FILE=".last-branch", DEFAULT_PROMPT="PROMPT_build.md", PLAN_PROMPT="PROMPT_plan.md", REQUIRED_DIRS=("specs"), ARCHIVE_FILES=("IMPLEMENTATION_PLAN.md" "AGENTS.md")
- [ ] 2.2 Create `variants/ralphus-review/config.sh` with: VARIANT_NAME="review", TRACKING_FILE="REVIEW_PLAN.md", LAST_BRANCH_FILE=".last-review-branch", DEFAULT_PROMPT="PROMPT_review_build.md", PLAN_PROMPT="PROMPT_review_plan.md", ARCHIVE_FILES=("REVIEW_PLAN.md" "reviews"), EXTRA_SIGNALS=("APPROVED")
- [ ] 2.3 Create `variants/ralphus-architect/config.sh` with: VARIANT_NAME="architect", TRACKING_FILE="", LAST_BRANCH_FILE=".last-architect-branch", DEFAULT_PROMPT="PROMPT_architect.md", LOOP_TYPE="file-iterator"
- [ ] 2.4 Create `variants/ralphus-product/config.sh` with: VARIANT_NAME="product", DEFAULT_PROMPT="PROMPT_product.md", PLAN_PROMPT="PROMPT_product_init.md", REQUIRED_DIRS=("inbox"), LOOP_TYPE="sequential"
- [ ] 2.5 Create `variants/ralphus-test/config.sh` with: VARIANT_NAME="test", TRACKING_FILE="test-specs/*.md", DEFAULT_PROMPT="PROMPT_test_build.md", PLAN_PROMPT="PROMPT_test_plan.md"
- [ ] 2.6 Create `variants/ralphus-research/config.sh` with: VARIANT_NAME="research", TRACKING_FILE="RESEARCH_PLAN.md", DEFAULT_PROMPT="PROMPT_research_build.md", PLAN_PROMPT="PROMPT_research_plan.md"
- [ ] 2.7 Create `variants/ralphus-discover/config.sh` with: VARIANT_NAME="discover", TRACKING_FILE="DISCOVERY_PLAN.md", DEFAULT_PROMPT="PROMPT_discover_build.md", PLAN_PROMPT="PROMPT_discover_plan.md"

---

## Phase 3: Refactor Variant Loop Scripts

- [ ] 3.1 Refactor `variants/ralphus-code/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement get_templates() returning IMPLEMENTATION_PLAN_REFERENCE.md; implement validate_variant() checking specs/ and IMPLEMENTATION_PLAN.md; call run_loop "$@"
- [ ] 3.2 Refactor `variants/ralphus-review/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement parse_variant_args() for pr/diff/files targets; implement validate_variant() for PR mode branch check; implement get_templates() returning 3 template files; implement build_message() adding REVIEW_TARGET and MAIN_BRANCH; implement post_iteration() for review artifact commits; call run_loop "$@"
- [ ] 3.3 Refactor `variants/ralphus-architect/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; ADD MISSING SHUTDOWN HANDLER via setup_shutdown_handler(); implement parse_variant_args() for feature/triage modes; implement file-iterator loop pattern; call run_loop "$@"
- [ ] 3.4 Refactor `variants/ralphus-product/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement sequential (non-loop) pattern; keep init/process modes; call run_sequential "$@"
- [ ] 3.5 Refactor `variants/ralphus-test/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement get_templates() for test templates; call run_loop "$@"
- [ ] 3.6 Refactor `variants/ralphus-research/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement get_templates() for research templates; call run_loop "$@"
- [ ] 3.7 Refactor `variants/ralphus-discover/scripts/loop.sh`: Source config.sh and lib/loop_core.sh; implement get_templates() for discover templates; call run_loop "$@"

---

## Phase 4: Propagate Custom Prompt Injection

- [ ] 4.1 Ensure parse_common_args() handles custom strings/files: check if arg is file with -f, cat and append; else append as string
- [ ] 4.2 Ensure build_base_message() appends CUSTOM_PROMPT when set
- [ ] 4.3 Test custom prompt with each variant: `ralphus code "focus on tests"`, `ralphus review "check security only"`, `ralphus architect feature "prioritize API design"`

---

## Phase 5: Validation

- [ ] 5.1 Run `bash -n lib/loop_core.sh` - verify syntax
- [ ] 5.2 Run `bash -n variants/*/scripts/loop.sh` - verify all variant scripts
- [ ] 5.3 Run `shellcheck lib/loop_core.sh` - fix any warnings
- [ ] 5.4 Run `shellcheck variants/*/scripts/loop.sh` - fix any warnings
- [ ] 5.5 Test `ralphus code plan` - verify plan mode works
- [ ] 5.6 Test `ralphus code` - verify build mode works
- [ ] 5.7 Test `ralphus code ulw 5` - verify ultrawork and max iterations
- [ ] 5.8 Test `ralphus code "custom instructions"` - verify prompt injection
- [ ] 5.9 Test `ralphus review plan pr` - verify PR mode
- [ ] 5.10 Test `ralphus architect feature` - verify feature mode
- [ ] 5.11 Test `ralphus architect triage` - verify triage mode
- [ ] 5.12 Test `ralphus product init` - verify init mode
- [ ] 5.13 Test Ctrl+C during loop - verify graceful shutdown
- [ ] 5.14 Run `wc -l lib/loop_core.sh variants/*/scripts/loop.sh` - verify line count reduction

---

## Phase 6: Documentation

- [ ] 6.1 Update `AGENTS.md` Operational Notes section with new architecture
- [ ] 6.2 Add inline comments in `lib/loop_core.sh` explaining hook system
- [ ] 6.3 Update usage comments in each variant's loop.sh

---

## Notes

- **Zero Breaking Changes**: All existing `ralphus <variant>` commands must work identically
- **Priority**: Phase 1 > Phase 2 > Phase 3 (parallel within phase) > Phase 4 > Phase 5 > Phase 6
- **Dependencies**: Phase 3 depends on Phase 1+2 completion; Phase 4 verifies Phase 3; Phase 5 is testing
