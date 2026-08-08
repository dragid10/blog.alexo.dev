#!/usr/bin/env bash
# sync-back.sh — Copy a published post back into its Obsidian draft.
#
# Run once, right before merging a PR, after any content fixes made
# directly in the repo (e.g. from reading the Vercel preview). Copies
# the whole file, frontmatter included — once published, the repo
# version is the correct state. Only the image paths get rewritten
# (/assets/uploads/<slug>/ → images/<slug>/, undoing publish.sh's
# rewrite) so images still resolve from within the vault.
set -euo pipefail
cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
sync-back.sh - copy a repo post back into its Obsidian draft

Usage:
  ./scripts/sync-back.sh <slug> [--dry-run]

Examples:
  ./scripts/sync-back.sh whats-up-with-alex-vol2 --dry-run
  ./scripts/sync-back.sh whats-up-with-alex-vol2

Copies src/content/posts/<slug>.md into the matching Obsidian draft,
whole file (frontmatter and body). Image paths are rewritten back to
the vault's images/<slug>/ convention.

--dry-run prints a diff instead of writing.

Environment:
  OBSIDIAN_POSTS_PATH   Path to your Obsidian blog posts folder
                        (no default — set in your shell config)
EOF
}

REPO_POSTS_DIR="src/content/posts"
OBSIDIAN_POSTS_PATH="${OBSIDIAN_POSTS_PATH:-}"

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
SLUG=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) SLUG="$1"; shift ;;
  esac
done

if [ -z "$SLUG" ]; then
  usage
  exit 1
fi

REPO_FILE="$REPO_POSTS_DIR/$SLUG.md"
if [ ! -f "$REPO_FILE" ]; then
  echo "Repo post not found: $REPO_FILE" >&2
  exit 1
fi

if [ -z "$OBSIDIAN_POSTS_PATH" ]; then
  echo "OBSIDIAN_POSTS_PATH is not set." >&2
  exit 1
fi

# Resolve the vault file: exact slug match first, then a unique
# substring match (vault filenames sometimes carry a date prefix or
# differ from the published --slug override).
VAULT_FILE=""
if [ -f "$OBSIDIAN_POSTS_PATH/$SLUG.md" ]; then
  VAULT_FILE="$OBSIDIAN_POSTS_PATH/$SLUG.md"
else
  matches=("$OBSIDIAN_POSTS_PATH"/*"$SLUG"*.md)
  if [ -f "${matches[0]:-}" ] && [ ${#matches[@]} -eq 1 ]; then
    VAULT_FILE="${matches[0]}"
  else
    echo "Could not find a unique vault draft matching '$SLUG' in $OBSIDIAN_POSTS_PATH" >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Undo publish.sh's image-path rewrite, then compare/write
# ---------------------------------------------------------------------------
repo_content="$(sed "s|/assets/uploads/$SLUG/|images/$SLUG/|g" "$REPO_FILE")"
vault_content="$(cat "$VAULT_FILE")"

if [ "$repo_content" = "$vault_content" ]; then
  echo "Already in sync: $VAULT_FILE"
  exit 0
fi

if [ "$DRY_RUN" -eq 1 ]; then
  diff -u <(echo "$vault_content") <(echo "$repo_content") || true
  echo ""
  echo "(dry run — vault file not modified: $VAULT_FILE)"
  exit 0
fi

printf '%s\n' "$repo_content" > "$VAULT_FILE"
echo "Synced → $VAULT_FILE"
