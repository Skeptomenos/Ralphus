# variants/ralphus-research/config.sh
# Configuration for the ralphus-research variant (autonomous learning loop)

VARIANT_NAME="research"
TRACKING_FILE="ralph-wiggum/research/plan.md"
LAST_BRANCH_FILE=".last-branch"
DEFAULT_PROMPT="PROMPT_research_build.md"
PLAN_PROMPT="PROMPT_research_plan.md"
REQUIRED_DIRS=("ralph-wiggum/research/inbox" "ralph-wiggum/research/artifacts")
ARCHIVE_FILES=("ralph-wiggum/research/plan.md" "ralph-wiggum/research/artifacts")
