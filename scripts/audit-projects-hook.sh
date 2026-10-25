#!/usr/bin/env bash
# audit-projects-hook.sh — pre-commit wrapper around audit-projects.sh.
#
# Runs only when the commit adds, removes, or renames a project card. It then
# runs `audit-projects.sh --write` and, if any card's status changed, stops the
# commit so the changes can be reviewed, staged, and committed again.
#
# Never blocks a commit it can't check: if gh is missing, not logged in, or
# GitHub is unreachable, it prints a warning and lets the commit through.
#
# Skip it once with: SKIP=audit-projects git commit ...
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECTS_DIR="src/content/projects"
LOCAL_REPOS_FILE="scripts/project-repos.local"

# Pre-commit's `files:` filter ignores deleted files, so check the staged diff directly.
if [ -z "$(git diff --cached --name-only --diff-filter=ADR -- "$PROJECTS_DIR/*.md")" ]; then
  exit 0
fi

warn() { echo "audit-projects: $*, skipping the status check." >&2; }

command -v gh >/dev/null || { warn "gh is not installed"; exit 0; }
gh auth token >/dev/null 2>&1 || { warn "gh is not logged in"; exit 0; }
gh api --method GET rate_limit --silent >/dev/null 2>&1 || { warn "GitHub is unreachable"; exit 0; }

if [ ! -f "$LOCAL_REPOS_FILE" ]; then
  echo "audit-projects: $LOCAL_REPOS_FILE not found; cards without a repo link will be skipped." >&2
fi

before=$(git diff -- "$PROJECTS_DIR")
./scripts/audit-projects.sh --write
after=$(git diff -- "$PROJECTS_DIR")

if [ "$before" != "$after" ]; then
  echo
  echo "Project statuses were updated. Review them, git add, and commit again."
  exit 1
fi
