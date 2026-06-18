#!/usr/bin/env bash
# tag.sh — Interactive tag editor for blog posts.
#
# Lets you pick a post (from the blog repo or Obsidian vault), then
# select tags from the standard tag set using a multi-select TUI.
# Tags are written back into the post's YAML frontmatter.
#
# Requires: gum (https://github.com/charmbracelet/gum)
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

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO_POSTS_DIR="src/content/posts"
STANDARD_TAGS_FILE="scripts/tags.txt"
OBSIDIAN_POSTS_PATH="${OBSIDIAN_POSTS_PATH:-}"

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
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

if [ ! -f "$STANDARD_TAGS_FILE" ]; then
  echo "Tag list not found at $STANDARD_TAGS_FILE" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Helpers: frontmatter parsing
# ---------------------------------------------------------------------------

# Extract a single-line frontmatter field value from a markdown file.
# Usage: extract_frontmatter_field <file> <field_name>
extract_frontmatter_field() {
  local file="$1" field_name="$2"
  sed -n "/^---$/,/^---$/{s/^${field_name}: *\"\\(.*\\)\"/\\1/p; s/^${field_name}: *\\(.*\\)/\\1/p}" "$file" | head -1
}

# Extract the tags array from frontmatter as a newline-separated list.
# Handles both quoted ("tag") and unquoted (tag) YAML list items.
# Usage: extract_frontmatter_tags <file>
extract_frontmatter_tags() {
  local file="$1"
  sed -n '/^tags:/,/^[a-zA-Z]/{s/^  - "\(.*\)"/\1/p; s/^  - \(.*\)/\1/p}' "$file"
}

# Build a display label for a post: "YYYY-MM-DD  Title"
# Used in the gum picker to help identify posts at a glance.
format_post_label() {
  local file="$1"
  local pub_date post_title
  pub_date="$(extract_frontmatter_field "$file" "pubDatetime" | cut -c1-10)"
  post_title="$(extract_frontmatter_field "$file" "title")"
  printf "%s  %s" "$pub_date" "$post_title"
}

# ---------------------------------------------------------------------------
# Helpers: post listing and selection
# ---------------------------------------------------------------------------

# List all markdown files in a directory, sorted by pubDatetime (newest first).
# Prints one file path per line to stdout.
list_posts_newest_first() {
  local posts_dir="$1"
  for file in "$posts_dir"/*.md; do
    [ -f "$file" ] || continue
    pub_date="$(extract_frontmatter_field "$file" "pubDatetime" | cut -c1-10)"
    printf "%s\t%s\n" "$pub_date" "$file"
  done | sort -t$'\t' -k1 -r | cut -f2
}

# Present an interactive picker to choose a single post from a directory.
# Sets the global SELECTED_POST_FILE variable with the chosen file path.
pick_post_from_directory() {
  local posts_dir="$1"
  declare -a available_files=()
  declare -a display_labels=()

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    available_files+=("$file")
    display_labels+=("$(format_post_label "$file")")
  done < <(list_posts_newest_first "$posts_dir")

  if [ ${#available_files[@]} -eq 0 ]; then
    echo "No posts found in $posts_dir" >&2
    exit 1
  fi

  chosen_label="$(printf '%s\n' "${display_labels[@]}" | gum choose --header "Pick a post to tag:")"

  SELECTED_POST_FILE=""
  for i in "${!display_labels[@]}"; do
    if [ "${display_labels[$i]}" = "$chosen_label" ]; then
      SELECTED_POST_FILE="${available_files[$i]}"
      break
    fi
  done

  if [ -z "$SELECTED_POST_FILE" ]; then
    echo "Could not match selection to a file" >&2
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Step 1: Pick a post to tag
# ---------------------------------------------------------------------------

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
esac

if [ "${1:-}" != "" ]; then
  # Slug passed as argument — resolve directly
  SELECTED_POST_FILE="$REPO_POSTS_DIR/$1.md"
  if [ ! -f "$SELECTED_POST_FILE" ]; then
    echo "Post not found: $SELECTED_POST_FILE" >&2
    exit 1
  fi
else
  # No slug given — build a list of available sources (repo + Obsidian)
  declare -a source_labels=()
  declare -a source_directories=()

  if compgen -G "$REPO_POSTS_DIR/*.md" >/dev/null 2>&1; then
    source_labels+=("Blog repo  (src/content/posts/)")
    source_directories+=("$REPO_POSTS_DIR")
  fi
  if [ -n "$OBSIDIAN_POSTS_PATH" ] && [ -d "$OBSIDIAN_POSTS_PATH" ] && compgen -G "$OBSIDIAN_POSTS_PATH/*.md" >/dev/null 2>&1; then
    source_labels+=("Obsidian   ($(basename "$(dirname "$OBSIDIAN_POSTS_PATH")")/posts/)")
    source_directories+=("$OBSIDIAN_POSTS_PATH")
  fi

  if [ ${#source_labels[@]} -eq 0 ]; then
    echo "No posts found in $REPO_POSTS_DIR${OBSIDIAN_POSTS_PATH:+ or $OBSIDIAN_POSTS_PATH}" >&2
    exit 1
  elif [ ${#source_labels[@]} -eq 1 ]; then
    # Only one source available — skip the source picker
    pick_post_from_directory "${source_directories[0]}"
  else
    # Multiple sources — let the user choose where to look
    chosen_source="$(printf '%s\n' "${source_labels[@]}" | gum choose --header "Where are the posts?")"
    for i in "${!source_labels[@]}"; do
      if [ "${source_labels[$i]}" = "$chosen_source" ]; then
        pick_post_from_directory "${source_directories[$i]}"
        break
      fi
    done
  fi
fi

post_title="$(extract_frontmatter_field "$SELECTED_POST_FILE" "title")"
echo ""
gum style --bold "Tagging: $post_title"
echo ""

# ---------------------------------------------------------------------------
# Step 2: Show the post's current tags
# ---------------------------------------------------------------------------
current_tags="$(extract_frontmatter_tags "$SELECTED_POST_FILE")"
if [ -n "$current_tags" ]; then
  echo "Current tags:"
  while IFS= read -r tag; do
    echo "  - $tag"
  done <<< "$current_tags"
  echo ""
fi

# ---------------------------------------------------------------------------
# Step 3: Pick new tags from the standard set
# ---------------------------------------------------------------------------

# Pre-select any current tags that exist in the standard set, so the user
# sees them already checked in the picker.
preselected_tags=()
all_standard_tags="$(grep -v '^$' "$STANDARD_TAGS_FILE")"

while IFS= read -r tag; do
  [ -z "$tag" ] && continue
  # Case-insensitive match against the standard tag list
  matched_tag="$(echo "$all_standard_tags" | grep -ix "$tag" || true)"
  if [ -n "$matched_tag" ]; then
    preselected_tags+=("$matched_tag")
  fi
done <<< "$current_tags"

# Build the --selected flag for gum (comma-separated list of pre-checked tags)
preselected_csv=""
if [ ${#preselected_tags[@]} -gt 0 ]; then
  preselected_csv="$(printf '%s,' "${preselected_tags[@]}")"
  preselected_csv="${preselected_csv%,}"  # strip trailing comma
fi

chosen_tags=""
if [ -n "$preselected_csv" ]; then
  chosen_tags="$(echo "$all_standard_tags" | gum choose --no-limit --header "Select tags (space to toggle):" --selected "$preselected_csv")" || true
else
  chosen_tags="$(echo "$all_standard_tags" | gum choose --no-limit --header "Select tags (space to toggle):")" || true
fi

if [ -z "$chosen_tags" ]; then
  echo "No tags selected — keeping existing tags."
  exit 0
fi

# ---------------------------------------------------------------------------
# Step 4: Confirm and write tags to frontmatter
# ---------------------------------------------------------------------------
echo ""
echo "New tags:"
while IFS= read -r tag; do
  echo "  - $tag"
done <<< "$chosen_tags"
echo ""

gum confirm "Apply these tags to $(basename "$SELECTED_POST_FILE")?" || { echo "Cancelled."; exit 0; }

# Build the replacement YAML block for the tags field
new_tags_yaml="tags:"
while IFS= read -r tag; do
  new_tags_yaml="$new_tags_yaml
  - \"$tag\""
done <<< "$chosen_tags"

# Replace the tags block in the file using awk.
# Strategy: match the "tags:" line and all indented list items below it,
# then swap in the new block. Everything else passes through unchanged.
temp_file="$(mktemp)"
awk -v new_block="$new_tags_yaml" '
  /^tags:/ {
    print new_block
    inside_tags_block = 1
    next
  }
  inside_tags_block && /^  - / { next }
  { inside_tags_block = 0; print }
' "$SELECTED_POST_FILE" > "$temp_file"

mv "$temp_file" "$SELECTED_POST_FILE"

echo ""
gum style --foreground 2 "Done! Tags updated in $(basename "$SELECTED_POST_FILE")"
