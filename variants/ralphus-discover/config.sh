# variants/ralphus-discover/config.sh
# Configuration for the ralphus-discover variant (autonomous codebase exploration)

VARIANT_NAME="discover"
TRACKING_FILE="ralph-wiggum/discover/plan.md"
LAST_BRANCH_FILE=".last-branch"
DEFAULT_PROMPT="PROMPT_discover_build.md"
PLAN_PROMPT="PROMPT_discover_plan.md"
REQUIRED_DIRS=("ralph-wiggum/discover/inbox" "ralph-wiggum/discover/artifacts")
ARCHIVE_FILES=("ralph-wiggum/discover/plan.md" "ralph-wiggum/discover/artifacts")
