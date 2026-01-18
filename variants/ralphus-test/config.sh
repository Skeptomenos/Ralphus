# variants/ralphus-test/config.sh
# Configuration for the ralphus-test variant (autonomous test creation/implementation)

VARIANT_NAME="test"
TRACKING_FILE=""                          # Uses test-specs/*.md instead of single tracking file
LAST_BRANCH_FILE=".last-branch"
DEFAULT_PROMPT="PROMPT_test_build.md"
PLAN_PROMPT="PROMPT_test_plan.md"
REQUIRED_DIRS=("test-specs")
ARCHIVE_FILES=("test-specs")
