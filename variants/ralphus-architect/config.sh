# variants/ralphus-architect/config.sh
# Configuration for the ralphus-architect variant (specification generation from ideas/reviews)

VARIANT_NAME="architect"
TRACKING_FILE="ralph-wiggum/architect/plan.md"
LAST_BRANCH_FILE=".last-architect-branch"
DEFAULT_PROMPT="PROMPT_architect.md"
PLAN_PROMPT=""
REQUIRED_DIRS=("ralph-wiggum/prds" "ralph-wiggum/specs")
ARCHIVE_FILES=("ralph-wiggum/architect/plan.md")
LOOP_TYPE="file-iterator"
