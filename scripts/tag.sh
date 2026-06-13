#!/usr/bin/env bash
# Interactive tag editor for blog posts. Uses gum for the TUI.
#
#   ./scripts/tag.sh            # pick a post, then pick tags
#   ./scripts/tag.sh <slug>     # jump straight to tagging a specific post
#
# Reads the canonical tag list from scripts/tags.txt.
# Requires: gum (https://github.com/charmbracelet/gum)

set -euo pipefail
cd "$(dirname "$0")/.."

POSTS_DIR="src/content/posts"
TAGS_FILE="scripts/tags.txt"

# --- dependency check ---
if ! command -v gum &>/dev/null; then
  echo "gum is required but not installed."
  echo ""
  echo "Install via one of:"
  echo "  go install github.com/charmbracelet/gum@latest"
  echo "  brew install gum"
  echo "  sudo dnf install gum"
  echo ""
  echo "See https://github.com/charmbracelet/gum#installation"
  exit 1
fi

if [ ! -f "$TAGS_FILE" ]; then
  echo "Tag list not found at $TAGS_FILE" >&2
  exit 1
fi

# --- helpers ---

# Extract a frontmatter field value (single-line string fields only)
fm_field() {
  local file="$1" field="$2"
  sed -n "/^---$/,/^---$/{s/^${field}: *\"\\(.*\\)\"/\\1/p; s/^${field}: *\\(.*\\)/\\1/p}" "$file" | head -1
}

# Extract tags array from frontmatter as newline-separated list
fm_tags() {
  local file="$1"
  sed -n '/^tags:/,/^[a-zA-Z]/{s/^  - "\(.*\)"/\1/p; s/^  - \(.*\)/\1/p}' "$file"
}

# Build a display line for a post: "YYYY-MM-DD  Title"
post_display() {
  local file="$1"
  local date title
  date="$(fm_field "$file" "pubDatetime" | cut -c1-10)"
  title="$(fm_field "$file" "title")"
  printf "%s  %s" "$date" "$title"
}

# --- pick a post ---

if [ "${1:-}" != "" ]; then
  POST_FILE="$POSTS_DIR/$1.md"
  if [ ! -f "$POST_FILE" ]; then
    echo "Post not found: $POST_FILE" >&2
    exit 1
  fi
else
  # Build list of posts sorted by pubDatetime
  declare -a post_files=()
  declare -a post_labels=()

  while IFS= read -r file; do
    post_files+=("$file")
    post_labels+=("$(post_display "$file")")
  done < <(
    for f in "$POSTS_DIR"/*.md; do
      date="$(fm_field "$f" "pubDatetime" | cut -c1-10)"
      printf "%s\t%s\n" "$date" "$f"
    done | sort -t$'\t' -k1 | cut -f2
  )

  if [ ${#post_files[@]} -eq 0 ]; then
    echo "No posts found in $POSTS_DIR" >&2
    exit 1
  fi

  # gum choose returns the selected label text
  CHOSEN_LABEL="$(printf '%s\n' "${post_labels[@]}" | gum choose --header "Pick a post to tag:")"

  # Find the matching file
  POST_FILE=""
  for i in "${!post_labels[@]}"; do
    if [ "${post_labels[$i]}" = "$CHOSEN_LABEL" ]; then
      POST_FILE="${post_files[$i]}"
      break
    fi
  done

  if [ -z "$POST_FILE" ]; then
    echo "Could not match selection to a file" >&2
    exit 1
  fi
fi

POST_TITLE="$(fm_field "$POST_FILE" "title")"
echo ""
gum style --bold "Tagging: $POST_TITLE"
echo ""

# --- show current tags ---
CURRENT_TAGS="$(fm_tags "$POST_FILE")"
if [ -n "$CURRENT_TAGS" ]; then
  echo "Current tags:"
  while IFS= read -r t; do
    echo "  - $t"
  done <<< "$CURRENT_TAGS"
  echo ""
fi

# --- pick new tags ---

# Build --selected flag from current tags that exist in the standard set
SELECTED_ARGS=()
STANDARD_TAGS="$(cat "$TAGS_FILE" | grep -v '^$')"

while IFS= read -r current_tag; do
  [ -z "$current_tag" ] && continue
  # Case-insensitive match against standard tags
  match="$(echo "$STANDARD_TAGS" | grep -ix "$current_tag" || true)"
  if [ -n "$match" ]; then
    SELECTED_ARGS+=("$match")
  fi
done <<< "$CURRENT_TAGS"

SELECTED_FLAG=""
if [ ${#SELECTED_ARGS[@]} -gt 0 ]; then
  SELECTED_FLAG="$(printf '%s,' "${SELECTED_ARGS[@]}")"
  SELECTED_FLAG="${SELECTED_FLAG%,}"
fi

CHOSEN_TAGS=""
if [ -n "$SELECTED_FLAG" ]; then
  CHOSEN_TAGS="$(echo "$STANDARD_TAGS" | gum choose --no-limit --header "Select tags (space to toggle):" --selected "$SELECTED_FLAG")" || true
else
  CHOSEN_TAGS="$(echo "$STANDARD_TAGS" | gum choose --no-limit --header "Select tags (space to toggle):")" || true
fi

if [ -z "$CHOSEN_TAGS" ]; then
  echo "No tags selected — keeping existing tags."
  exit 0
fi

# --- confirm ---
echo ""
echo "New tags:"
while IFS= read -r t; do
  echo "  - $t"
done <<< "$CHOSEN_TAGS"
echo ""

gum confirm "Apply these tags to $(basename "$POST_FILE")?" || { echo "Cancelled."; exit 0; }

# --- write tags to frontmatter ---

# Build the new tags YAML block
NEW_TAGS_BLOCK="tags:"
while IFS= read -r t; do
  NEW_TAGS_BLOCK="$NEW_TAGS_BLOCK
  - \"$t\""
done <<< "$CHOSEN_TAGS"

# Replace the tags block in the file.
# Strategy: use awk to find the tags: line and everything indented under it,
# replace with the new block.
TMPFILE="$(mktemp)"
awk -v new_block="$NEW_TAGS_BLOCK" '
  /^tags:/ {
    print new_block
    in_tags = 1
    next
  }
  in_tags && /^  - / { next }
  { in_tags = 0; print }
' "$POST_FILE" > "$TMPFILE"

mv "$TMPFILE" "$POST_FILE"

echo ""
gum style --foreground 2 "Done! Tags updated in $(basename "$POST_FILE")"
