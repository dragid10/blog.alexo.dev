#!/usr/bin/env bash
# new.sh — Scaffold new site content (posts, projects, speaking engagements).
#
# Creates the markdown file (or YAML entry) with all required frontmatter
# fields pre-filled. Anything not passed as a flag is prompted for
# interactively (with a gum TUI if available, plain text otherwise).
#
# See --help for full usage.
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_POSTS_DIR="src/content/posts"
REPO_PROJECTS_DIR="src/content/projects"
SPEAKING_YAML_FILE="src/data/speaking.yaml"
STANDARD_TAGS_FILE="scripts/tags.txt"

# ---------------------------------------------------------------------------
# Usage / help text
# ---------------------------------------------------------------------------

usage() {
  cat <<'EOF'
new.sh - scaffold new site content (posts, projects, speaking engagements)

Usage:
  ./scripts/new.sh <command> [flags]

Commands:
  post       Create a new blog post draft
  project    Create a new project card
  talk       Add a speaking engagement to speaking.yaml

Examples:
  ./scripts/new.sh post
  ./scripts/new.sh post --title "My Post" --tags "python, tutorial"
  ./scripts/new.sh project --title "Cool App" --repo https://github.com/me/app
  ./scripts/new.sh talk --event "PyOhio 2026" --talk "My Talk"

Flags are optional. Anything not passed as a flag is prompted for
interactively. If gum is installed, the tag picker uses a multi-select
TUI instead of a plain text prompt.

Run ./scripts/new.sh <command> --help for command-specific flags.
EOF
}

usage_post() {
  cat <<'EOF'
new.sh post - create a new blog post draft

Usage:
  ./scripts/new.sh post [flags]

Examples:
  ./scripts/new.sh post
  ./scripts/new.sh post --title "My Post" --description "A short post"
  ./scripts/new.sh post --title "My Post" --tags "python, tutorial" --slug my-post

Flags:
  --title TITLE          Post title (required, prompted if omitted)
  --description DESC     One-sentence description for SEO/OG (required, prompted if omitted)
  --tags "TAG, TAG"      Comma-separated tags (prompted or gum picker if omitted)
  --slug SLUG            URL slug (default: derived from title)
  -h, --help             Show this help

Output: src/content/posts/<slug>.md with draft: true
EOF
}

usage_project() {
  cat <<'EOF'
new.sh project - create a new project card

Usage:
  ./scripts/new.sh project [flags]

Examples:
  ./scripts/new.sh project
  ./scripts/new.sh project --title "Cool App" --repo https://github.com/me/app

Flags:
  --title TITLE          Project title (required, prompted if omitted)
  --description DESC     One-liner for the card (required, prompted if omitted)
  --repo URL             Repository URL
  --demo URL             Live/demo URL
  --status STATUS        active, maintained, or archived (default: active)
  --tags "TAG, TAG"      Comma-separated tags
  --featured             Mark as featured on the projects page
  --order N              Sort order (number)
  --slug SLUG            Filename slug (default: derived from title)
  -h, --help             Show this help

Output: src/content/projects/<slug>.md
EOF
}

usage_talk() {
  cat <<'EOF'
new.sh talk - add a speaking engagement

Usage:
  ./scripts/new.sh talk [flags]

Examples:
  ./scripts/new.sh talk
  ./scripts/new.sh talk --event "PyOhio 2026" --talk "My Talk" --year 2026

Flags:
  --year YEAR            Year (default: current year)
  --event NAME           Event name (required, prompted if omitted)
  --type TYPE            Conference talk, Guest lecture, Podcast, Panel, or Workshop
                         (default: Conference talk)
  --talk TITLE           Talk title (required, prompted if omitted)
  --recap URL            Recap blog post URL
  --slides URL           Slides URL
  --video URL            Video URL
  -h, --help             Show this help

Output: appended to src/data/speaking.yaml
EOF
}

# ---------------------------------------------------------------------------
# Parse the subcommand and flags
# ---------------------------------------------------------------------------

SUBCOMMAND="${1:-}"
[ $# -gt 0 ] && shift

case "$SUBCOMMAND" in
  -h|--help) usage; exit 0 ;;
esac

# All possible flag values — initialized empty
TITLE="" DESCRIPTION="" TAGS="" URL_SLUG="" REPO_URL="" DEMO_URL="" STATUS=""
IS_FEATURED="" SORT_ORDER="" YEAR="" EVENT_NAME="" TALK_TYPE="" TALK_TITLE=""
RECAP_URL="" SLIDES_URL="" VIDEO_URL=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      case "$SUBCOMMAND" in
        post)          usage_post ;;
        project)       usage_project ;;
        talk|speaking) usage_talk ;;
        *)             usage ;;
      esac
      exit 0 ;;
    --title)       TITLE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --tags)        TAGS="$2"; shift 2 ;;
    --slug)        URL_SLUG="$2"; shift 2 ;;
    --repo)        REPO_URL="$2"; shift 2 ;;
    --demo)        DEMO_URL="$2"; shift 2 ;;
    --status)      STATUS="$2"; shift 2 ;;
    --featured)    IS_FEATURED="y"; shift ;;
    --order)       SORT_ORDER="$2"; shift 2 ;;
    --year)        YEAR="$2"; shift 2 ;;
    --event)       EVENT_NAME="$2"; shift 2 ;;
    --type)        TALK_TYPE="$2"; shift 2 ;;
    --talk)        TALK_TITLE="$2"; shift 2 ;;
    --recap)       RECAP_URL="$2"; shift 2 ;;
    --slides)      SLIDES_URL="$2"; shift 2 ;;
    --video)       VIDEO_URL="$2"; shift 2 ;;
    *) echo "Unknown flag: $1" >&2; echo "Run ./scripts/new.sh $SUBCOMMAND --help for usage." >&2; exit 1 ;;
  esac
done

# Check if gum is available for interactive prompts
HAS_GUM=""
command -v gum &>/dev/null && [ -t 0 ] && HAS_GUM="y"

# ---------------------------------------------------------------------------
# Shared helper functions
# ---------------------------------------------------------------------------

# Prompt the user for a value if the corresponding variable is empty.
# Usage: prompt_for_value VARIABLE_NAME "Prompt text" [default_value] [required]
#   - If the variable already has a value, does nothing.
#   - In non-interactive mode (piped stdin), uses the default or errors if required.
#   - Uses gum for input if available, falls back to plain read.
prompt_for_value() {
  local variable_name="$1" prompt_text="$2" default_value="${3:-}" is_required="${4:-}"
  local current_value user_input

  current_value="$(eval "printf '%s' \"\$$variable_name\"")"
  [ -n "$current_value" ] && return 0

  # Non-interactive mode: use default or fail
  if [ ! -t 0 ]; then
    if [ -n "$is_required" ]; then
      echo "Missing required value: --$(printf '%s' "$variable_name" | tr '[:upper:]' '[:lower:]')" >&2
      exit 1
    fi
    eval "$variable_name=\$default_value"
    return 0
  fi

  # Interactive mode with gum
  if [ -n "$HAS_GUM" ]; then
    local gum_args=(--header "$prompt_text")
    [ -n "$default_value" ] && gum_args+=(--value "$default_value")
    while true; do
      user_input="$(gum input "${gum_args[@]}")" || true
      if [ -n "$user_input" ] || [ -z "$is_required" ]; then
        eval "$variable_name=\$user_input"
        return 0
      fi
      echo "  (required)" >&2
    done
  fi

  # Interactive mode without gum (plain read)
  while true; do
    if [ -n "$default_value" ]; then
      read -r -p "$prompt_text [$default_value]: " user_input
      user_input="${user_input:-$default_value}"
    else
      read -r -p "$prompt_text: " user_input
    fi
    if [ -n "$user_input" ] || [ -z "$is_required" ]; then
      eval "$variable_name=\$user_input"
      return 0
    fi
    echo "  (required)"
  done
}

# Convert a title to a URL-safe slug: lowercase, ASCII alphanumeric, kebab-case.
# Usage: title_to_slug "My Cool Post Title"
title_to_slug() {
  local slug
  slug="$(printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -e 's/[^a-z0-9 _-]//g' -e 's/[ _][ _]*/-/g' -e 's/--*/-/g' -e 's/^-*//' -e 's/-*$//')"
  if [ -z "$slug" ]; then
    echo "Could not derive a filename slug from that title; pass one with --slug" >&2
    exit 1
  fi
  printf '%s' "$slug"
}

# Escape double quotes for use in YAML double-quoted scalars.
# Usage: yaml_quote "Some \"quoted\" text"
yaml_quote() { printf '"%s"' "$(printf '%s' "$1" | sed 's/"/\\"/g')"; }

# Convert a comma-separated tag string into YAML list items (one per line).
# Usage: tags_to_yaml_list "python, tutorial, web"
tags_to_yaml_list() {
  printf '%s\n' "$1" | tr ',' '\n' | while IFS= read -r tag; do
    tag="$(printf '%s' "$tag" | sed -e 's/^ *//' -e 's/ *$//')"  # trim whitespace
    [ -z "$tag" ] && continue
    printf '  - "%s"\n' "$tag"
  done
}

# Present a multi-select gum picker for the standard tag set.
# Returns comma-separated selected tags, or fails (return 1) if
# gum/tags.txt is unavailable or the user cancels.
pick_tags_with_gum() {
  command -v gum &>/dev/null || return 1
  [ -t 0 ] || return 1
  [ -f "$STANDARD_TAGS_FILE" ] || return 1

  local selected_tags
  selected_tags="$(grep -v '^$' "$STANDARD_TAGS_FILE" \
    | gum choose --no-limit --header "Select tags (space to toggle):")" || true
  [ -z "$selected_tags" ] && return 1
  printf '%s' "$selected_tags" | paste -sd ',' -
}

# Exit with an error if the given file path already exists.
refuse_if_file_exists() {
  if [ -e "$1" ]; then
    echo "Refusing to overwrite existing file: $1" >&2
    exit 1
  fi
}

# Clean up a title: trim leading/trailing spaces, collapse doubled spaces.
clean_title() {
  printf '%s' "$1" | sed -e 's/^ *//' -e 's/ *$//' -e 's/  */ /g'
}

# ---------------------------------------------------------------------------
# Subcommand: post
# ---------------------------------------------------------------------------
new_post() {
  prompt_for_value TITLE "Post title" "" required
  TITLE="$(clean_title "$TITLE")"
  prompt_for_value DESCRIPTION "Description (one sentence, used for SEO/OG)" "" required

  # Tags: try gum picker first, fall back to text prompt
  if [ -z "$TAGS" ]; then
    TAGS="$(pick_tags_with_gum)" || true
  fi
  if [ -z "$TAGS" ]; then
    prompt_for_value TAGS "Tags (comma separated)" "others"
  fi

  [ -n "$URL_SLUG" ] || URL_SLUG="$(title_to_slug "$TITLE")"
  local output_path="$REPO_POSTS_DIR/$URL_SLUG.md"
  refuse_if_file_exists "$output_path"

  {
    echo "---"
    echo "title: $(yaml_quote "$TITLE")"
    echo "description: $(yaml_quote "$DESCRIPTION")"
    echo "pubDatetime: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "tags:"
    tags_to_yaml_list "$TAGS"
    echo "draft: true"
    echo "---"
    echo ""
  } > "$output_path"

  echo ""
  echo "Created $output_path (draft)"
  echo "URL when published: /posts/$URL_SLUG/"
  echo "Write the post, set draft: false, then open a PR."
}

# ---------------------------------------------------------------------------
# Subcommand: project
# ---------------------------------------------------------------------------
new_project() {
  prompt_for_value TITLE "Project title" "" required
  prompt_for_value DESCRIPTION "Description (one-liner for the card)" "" required
  prompt_for_value REPO_URL "Repo URL (blank to skip)"
  prompt_for_value DEMO_URL "Demo/live URL (blank to skip)"

  # Status: gum chooser or text prompt
  if [ -z "$STATUS" ] && [ -n "$HAS_GUM" ]; then
    STATUS="$(printf 'active\nmaintained\narchived' | gum choose --header "Status:")"
  else
    prompt_for_value STATUS "Status" "active"
    case "$STATUS" in active|maintained|archived) ;; *) echo "Invalid status: $STATUS" >&2; exit 1 ;; esac
  fi

  prompt_for_value TAGS "Tags (comma separated, lowercase)"

  # Featured: gum confirm or text prompt
  if [ -z "$IS_FEATURED" ] && [ -n "$HAS_GUM" ]; then
    gum confirm "Featured on the projects page?" && IS_FEATURED="y" || IS_FEATURED="n"
  else
    prompt_for_value IS_FEATURED "Featured? (y/N)" "n"
  fi

  prompt_for_value SORT_ORDER "Order (number, blank to skip)"

  [ -n "$URL_SLUG" ] || URL_SLUG="$(title_to_slug "$TITLE")"
  local output_path="$REPO_PROJECTS_DIR/$URL_SLUG.md"
  refuse_if_file_exists "$output_path"

  # Convert tags to inline YAML array format: ["tag1", "tag2"]
  local inline_tags=""
  if [ -n "$TAGS" ]; then
    inline_tags="$(printf '%s' "$TAGS" | tr '[:upper:]' '[:lower:]' | tr ',' '\n' \
      | sed -e 's/^ *//' -e 's/ *$//' -e '/^$/d' -e 's/.*/"&"/' | paste -sd ',' - | sed 's/,/, /g')"
  fi

  {
    echo "---"
    echo "title: $(yaml_quote "$TITLE")"
    echo "description: $(yaml_quote "$DESCRIPTION")"
    if [ -n "$REPO_URL" ]; then echo "repo: $(yaml_quote "$REPO_URL")"; fi
    if [ -n "$DEMO_URL" ]; then echo "demo: $(yaml_quote "$DEMO_URL")"; fi
    echo "status: $(yaml_quote "$STATUS")"
    if [ -n "$inline_tags" ]; then echo "tags: [$inline_tags]"; fi
    case "$IS_FEATURED" in y|Y|yes|true) echo "featured: true" ;; esac
    if [ -n "$SORT_ORDER" ]; then echo "order: $SORT_ORDER"; fi
    echo "---"
  } > "$output_path"

  echo ""
  echo "Created $output_path"
  echo "It will appear on /projects/ on the next deploy. Open a PR."
}

# ---------------------------------------------------------------------------
# Subcommand: talk
# ---------------------------------------------------------------------------
new_talk() {
  prompt_for_value YEAR "Year" "$(date +%Y)"
  prompt_for_value EVENT_NAME "Event name" "" required

  # Talk type: gum chooser or text prompt
  if [ -z "$TALK_TYPE" ] && [ -n "$HAS_GUM" ]; then
    TALK_TYPE="$(printf 'Conference talk\nGuest lecture\nPodcast\nPanel\nWorkshop' | gum choose --header "Type:")"
  else
    prompt_for_value TALK_TYPE "Type (Conference talk/Guest lecture/Podcast/Panel/Workshop)" "Conference talk"
  fi

  prompt_for_value TALK_TITLE "Talk title" "" required
  prompt_for_value RECAP_URL "Recap post URL (blank to skip)"
  prompt_for_value SLIDES_URL "Slides URL (blank to skip)"
  prompt_for_value VIDEO_URL "Video URL (blank to skip)"

  # Verify the speaking YAML file has the expected structure
  grep -q '^engagements:$' "$SPEAKING_YAML_FILE" || {
    echo "Could not find \"engagements:\" in $SPEAKING_YAML_FILE" >&2; exit 1
  }

  # Build the YAML entry for this engagement
  local yaml_entry
  yaml_entry="  - year: $YEAR
    event: $(yaml_quote "$EVENT_NAME")
    type: $(yaml_quote "$TALK_TYPE")
    talk: $(yaml_quote "$TALK_TITLE")"
  if [ -n "$RECAP_URL" ]; then yaml_entry="$yaml_entry
    recap: $(yaml_quote "$RECAP_URL")"; fi
  if [ -n "$SLIDES_URL" ]; then yaml_entry="$yaml_entry
    slides: $(yaml_quote "$SLIDES_URL")"; fi
  if [ -n "$VIDEO_URL" ]; then yaml_entry="$yaml_entry
    video: $(yaml_quote "$VIDEO_URL")"; fi

  # Insert the new entry right after the "engagements:" key (newest at top)
  awk -v entry="$yaml_entry" '{ print } /^engagements:$/ { print entry }' "$SPEAKING_YAML_FILE" \
    > "$SPEAKING_YAML_FILE.tmp" && mv "$SPEAKING_YAML_FILE.tmp" "$SPEAKING_YAML_FILE"

  echo ""
  echo "Added \"$TALK_TITLE\" ($EVENT_NAME, $YEAR) to $SPEAKING_YAML_FILE"
  echo "The speaking page groups by year automatically. Open a PR."
}

# ---------------------------------------------------------------------------
# Dispatch subcommand
# ---------------------------------------------------------------------------
case "$SUBCOMMAND" in
  post)            new_post ;;
  project)         new_project ;;
  talk|speaking)   new_talk ;;
  "")
    # No subcommand — let the user pick interactively if gum is available
    if [ -n "$HAS_GUM" ]; then
      SUBCOMMAND="$(printf 'post\nproject\ntalk' | gum choose --header "What would you like to create?")"
      case "$SUBCOMMAND" in
        post)    new_post ;;
        project) new_project ;;
        talk)    new_talk ;;
      esac
    else
      usage
    fi
    exit 0
    ;;
  *)
    echo "Unknown command: $SUBCOMMAND" >&2
    echo "Run ./scripts/new.sh --help for usage." >&2
    exit 1
    ;;
esac
