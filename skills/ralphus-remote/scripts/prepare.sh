#!/bin/bash
# prepare.sh - Remote version
# Usage: ./prepare.sh [target_dir] [branch_name]

[ -n "$1" ] && cd "$1"

# Source is fixed on remote
SOURCE_DIR="$HOME/Repos/ralphus/files"

# 1. Validate
if [ ! -d ".git" ]; then echo "Error: Not a git repo"; exit 1; fi
if [ -n "$(git status --porcelain)" ]; then echo "Error: Dirty working directory"; exit 1; fi

# 2. Scaffold
echo "Scaffolding files..."
cp -n "$SOURCE_DIR/loop.sh" . 2>/dev/null || true
cp -n "$SOURCE_DIR/PROMPT_build.md" . 2>/dev/null || true
cp -n "$SOURCE_DIR/PROMPT_plan.md" . 2>/dev/null || true
cp -n "$SOURCE_DIR/IMPLEMENTATION_PLAN.md" . 2>/dev/null || true
chmod +x loop.sh

# 3. Branch
BRANCH_NAME="${2:-ralphus/patch-$(date +%s)}"
echo "Switching to branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME"

echo "PREPARATION_COMPLETE"
