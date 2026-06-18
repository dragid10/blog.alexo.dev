#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

usage() {
  cat <<'EOF'
tag.sh - interactive tag editor for blog posts

Usage:
  ./scripts/tag.sh [slug]

Examples:
  ./scripts/tag.sh                    # pick source, post, then tags
  ./scripts/tag.sh avoid-pip-freeze   # tag a specific repo post by slug

When run without arguments, prompts you to choose between Obsidian
drafts and the blog repo, then pick a post, then select tags from
the standard set (scripts/tags.txt) with a multi-select TUI.

Environment:
  OBSIDIAN_POSTS_PATH   Path to your Obsidian blog posts folder
                   (no default — set in your shell config)

Requires: gum (https://github.com/charmbracelet/gum)
EOF
}

POSTS_DIR="src/content/posts"
TAGS_FILE="scripts/tags.txt"
OBSIDIAN_POSTS_PATH="${OBSIDIAN_POSTS_PATH:-}"

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

# Build a sorted post list from a directory. Prints file paths to stdout.
list_posts() {
  local dir="$1"
  for f in "$dir"/*.md; do
    [ -f "$f" ] || continue
    date="$(fm_field "$f" "pubDatetime" | cut -c1-10)"
    printf "%s\t%s\n" "$date" "$f"
  done | sort -t$'\t' -k1 -r | cut -f2
}

# Prompt user to pick a single post from a directory. Sets POST_FILE.
pick_post() {
  local dir="$1"
  declare -a post_files=()
  declare -a post_labels=()

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    post_files+=("$file")
    post_labels+=("$(post_display "$file")")
  done < <(list_posts "$dir")

  if [ ${#post_files[@]} -eq 0 ]; then
    echo "No posts found in $dir" >&2
    exit 1
  fi

  CHOSEN_LABEL="$(printf '%s\n' "${post_labels[@]}" | gum choose --header "Pick a post to tag:")"

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
}

# --- pick a post ---

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

if [ "${1:-}" != "" ]; then
  POST_FILE="$POSTS_DIR/$1.md"
  if [ ! -f "$POST_FILE" ]; then
    echo "Post not found: $POST_FILE" >&2
    exit 1
  fi
else
  # Build source list — only show options that actually have posts
  declare -a sources=()
  declare -a source_dirs=()

  if compgen -G "$POSTS_DIR/*.md" >/dev/null 2>&1; then
    sources+=("Blog repo  (src/content/posts/)")
    source_dirs+=("$POSTS_DIR")
  fi
  if [ -n "$OBSIDIAN_POSTS_PATH" ] && [ -d "$OBSIDIAN_POSTS_PATH" ] && compgen -G "$OBSIDIAN_POSTS_PATH/*.md" >/dev/null 2>&1; then
    sources+=("Obsidian   ($(basename "$(dirname "$OBSIDIAN_POSTS_PATH")")/posts/)")
    source_dirs+=("$OBSIDIAN_POSTS_PATH")
  fi

  if [ ${#sources[@]} -eq 0 ]; then
    echo "No posts found in $POSTS_DIR${OBSIDIAN_POSTS_PATH:+ or $OBSIDIAN_POSTS_PATH}" >&2
    exit 1
  elif [ ${#sources[@]} -eq 1 ]; then
    pick_post "${source_dirs[0]}"
  else
    SOURCE_LABEL="$(printf '%s\n' "${sources[@]}" | gum choose --header "Where are the posts?")"
    for i in "${!sources[@]}"; do
      if [ "${sources[$i]}" = "$SOURCE_LABEL" ]; then
        pick_post "${source_dirs[$i]}"
        break
      fi
    done
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
