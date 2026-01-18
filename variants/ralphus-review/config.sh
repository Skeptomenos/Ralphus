# variants/ralphus-review/config.sh
# Configuration for the ralphus-review variant (autonomous code review/audit)

VARIANT_NAME="review"
TRACKING_FILE="REVIEW_PLAN.md"
LAST_BRANCH_FILE=".last-review-branch"
DEFAULT_PROMPT="PROMPT_review_build.md"
PLAN_PROMPT="PROMPT_review_plan.md"
REQUIRED_DIRS=()
ARCHIVE_FILES=("REVIEW_PLAN.md" "reviews")
EXTRA_SIGNALS=("APPROVED")
