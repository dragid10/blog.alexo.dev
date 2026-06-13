#!/usr/bin/env bash
# Scaffold new site content. Requires bash + coreutils; gum is optional (tag picker).
#
#   ./scripts/new.sh post     [--title T] [--description D] [--tags "A, B"] [--slug S]
#   ./scripts/new.sh project  [--title T] [--description D] [--repo URL] [--demo URL]
#                             [--status active|maintained|archived] [--tags "a, b"]
#                             [--featured] [--order N] [--slug S]
#   ./scripts/new.sh talk     [--year Y] [--event E] [--type T] [--talk TITLE]
#                             [--recap URL] [--slides URL] [--video URL]
#
# Anything not passed as a flag is prompted for.

set -euo pipefail
cd "$(dirname "$0")/.."

POSTS_DIR="src/content/posts"
PROJECTS_DIR="src/content/projects"
SPEAKING_YAML="src/data/speaking.yaml"

CMD="${1:-}"
[ $# -gt 0 ] && shift

TITLE="" DESCRIPTION="" TAGS="" SLUG="" REPO="" DEMO="" STATUS="" FEATURED="" ORDER=""
YEAR="" EVENT="" TYPE="" TALK="" RECAP="" SLIDES="" VIDEO=""

while [ $# -gt 0 ]; do
  case "$1" in
    --title)       TITLE="$2"; shift 2 ;;
    --description) DESCRIPTION="$2"; shift 2 ;;
    --tags)        TAGS="$2"; shift 2 ;;
    --slug)        SLUG="$2"; shift 2 ;;
    --repo)        REPO="$2"; shift 2 ;;
    --demo)        DEMO="$2"; shift 2 ;;
    --status)      STATUS="$2"; shift 2 ;;
    --featured)    FEATURED="y"; shift ;;
    --order)       ORDER="$2"; shift 2 ;;
    --year)        YEAR="$2"; shift 2 ;;
    --event)       EVENT="$2"; shift 2 ;;
    --type)        TYPE="$2"; shift 2 ;;
    --talk)        TALK="$2"; shift 2 ;;
    --recap)       RECAP="$2"; shift 2 ;;
    --slides)      SLIDES="$2"; shift 2 ;;
    --video)       VIDEO="$2"; shift 2 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

# ask VARNAME "prompt" [default] [required]
ask() {
  local var="$1" prompt="$2" default="${3:-}" required="${4:-}" current value
  current="$(eval "printf '%s' \"\$$var\"")"
  [ -n "$current" ] && return 0
  if [ ! -t 0 ]; then
    if [ -n "$required" ]; then
      echo "Missing required value: --$(printf '%s' "$var" | tr '[:upper:]' '[:lower:]')" >&2
      exit 1
    fi
    eval "$var=\$default"
    return 0
  fi
  while true; do
    if [ -n "$default" ]; then
      read -r -p "$prompt [$default]: " value
      value="${value:-$default}"
    else
      read -r -p "$prompt: " value
    fi
    if [ -n "$value" ] || [ -z "$required" ]; then
      eval "$var=\$value"
      return 0
    fi
    echo "  (required)"
  done
}

# title -> safe filename/URL slug: lowercase kebab-case, ASCII alnum only
slugify() {
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

# escape double quotes for YAML double-quoted scalars
yq() { printf '"%s"' "$(printf '%s' "$1" | sed 's/"/\\"/g')"; }

# print "tag, tag" input as quoted YAML list items, one per line
tag_lines() {
  printf '%s\n' "$1" | tr ',' '\n' | while IFS= read -r t; do
    t="$(printf '%s' "$t" | sed -e 's/^ *//' -e 's/ *$//')"
    [ -z "$t" ] && continue
    printf '  - "%s"\n' "$t"
  done
}

TAGS_FILE="scripts/tags.txt"

# If gum + tags.txt are available and we're interactive, multi-select from the
# standard tag set. Returns comma-separated tags or "" if the user cancels.
pick_tags_gum() {
  command -v gum &>/dev/null || return 1
  [ -t 0 ] || return 1
  [ -f "$TAGS_FILE" ] || return 1

  local chosen
  chosen="$(grep -v '^$' "$TAGS_FILE" \
    | gum choose --no-limit --header "Select tags (space to toggle):")" || true
  [ -z "$chosen" ] && return 1
  printf '%s' "$chosen" | paste -sd ',' -
}

refuse_overwrite() {
  if [ -e "$1" ]; then
    echo "Refusing to overwrite existing file: $1" >&2
    exit 1
  fi
}

# trim, collapse doubled spaces
tidy_title() {
  printf '%s' "$1" | sed -e 's/^ *//' -e 's/ *$//' -e 's/  */ /g'
}

new_post() {
  ask TITLE "Post title" "" required
  TITLE="$(tidy_title "$TITLE")"
  ask DESCRIPTION "Description (one sentence, used for SEO/OG)" "" required
  if [ -z "$TAGS" ]; then
    TAGS="$(pick_tags_gum)" || true
  fi
  if [ -z "$TAGS" ]; then
    ask TAGS "Tags (comma separated)" "others"
  fi
  [ -n "$SLUG" ] || SLUG="$(slugify "$TITLE")"
  local path="$POSTS_DIR/$SLUG.md"
  refuse_overwrite "$path"

  {
    echo "---"
    echo "title: $(yq "$TITLE")"
    echo "description: $(yq "$DESCRIPTION")"
    echo "pubDatetime: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "tags:"
    tag_lines "$TAGS"
    echo "draft: true"
    echo "---"
    echo ""
  } > "$path"
  echo ""
  echo "Created $path (draft)"
  echo "URL when published: /posts/$SLUG/"
  echo "Write the post, set draft: false, then open a PR."
}

new_project() {
  ask TITLE "Project title" "" required
  ask DESCRIPTION "Description (one-liner for the card)" "" required
  ask REPO "Repo URL (blank to skip)"
  ask DEMO "Demo/live URL (blank to skip)"
  ask STATUS "Status" "active"
  case "$STATUS" in active|maintained|archived) ;; *) echo "Invalid status: $STATUS" >&2; exit 1 ;; esac
  ask TAGS "Tags (comma separated, lowercase)"
  ask FEATURED "Featured? (y/N)" "n"
  ask ORDER "Order (number, blank to skip)"
  [ -n "$SLUG" ] || SLUG="$(slugify "$TITLE")"
  local path="$PROJECTS_DIR/$SLUG.md"
  refuse_overwrite "$path"

  local tags_inline=""
  if [ -n "$TAGS" ]; then
    tags_inline="$(printf '%s' "$TAGS" | tr '[:upper:]' '[:lower:]' | tr ',' '\n' \
      | sed -e 's/^ *//' -e 's/ *$//' -e '/^$/d' -e 's/.*/"&"/' | paste -sd ',' - | sed 's/,/, /g')"
  fi

  {
    echo "---"
    echo "title: $(yq "$TITLE")"
    echo "description: $(yq "$DESCRIPTION")"
    if [ -n "$REPO" ]; then echo "repo: $(yq "$REPO")"; fi
    if [ -n "$DEMO" ]; then echo "demo: $(yq "$DEMO")"; fi
    echo "status: $(yq "$STATUS")"
    if [ -n "$tags_inline" ]; then echo "tags: [$tags_inline]"; fi
    case "$FEATURED" in y|Y|yes|true) echo "featured: true" ;; esac
    if [ -n "$ORDER" ]; then echo "order: $ORDER"; fi
    echo "---"
  } > "$path"
  echo ""
  echo "Created $path"
  echo "It will appear on /projects/ on the next deploy. Open a PR."
}

new_talk() {
  ask YEAR "Year" "$(date +%Y)"
  ask EVENT "Event name" "" required
  ask TYPE "Type (Conference talk/Guest lecture/Podcast/Panel/Workshop)" "Conference talk"
  ask TALK "Talk title" "" required
  ask RECAP "Recap post URL (blank to skip)"
  ask SLIDES "Slides URL (blank to skip)"
  ask VIDEO "Video URL (blank to skip)"

  grep -q '^engagements:$' "$SPEAKING_YAML" || {
    echo "Could not find \"engagements:\" in $SPEAKING_YAML" >&2; exit 1
  }

  local entry
  entry="  - year: $YEAR
    event: $(yq "$EVENT")
    type: $(yq "$TYPE")
    talk: $(yq "$TALK")"
  if [ -n "$RECAP" ]; then entry="$entry
    recap: $(yq "$RECAP")"; fi
  if [ -n "$SLIDES" ]; then entry="$entry
    slides: $(yq "$SLIDES")"; fi
  if [ -n "$VIDEO" ]; then entry="$entry
    video: $(yq "$VIDEO")"; fi

  # newest entries live at the top, right under the engagements: key
  awk -v entry="$entry" '{ print } /^engagements:$/ { print entry }' "$SPEAKING_YAML" \
    > "$SPEAKING_YAML.tmp" && mv "$SPEAKING_YAML.tmp" "$SPEAKING_YAML"
  echo ""
  echo "Added \"$TALK\" ($EVENT, $YEAR) to $SPEAKING_YAML"
  echo "The speaking page groups by year automatically. Open a PR."
}

case "$CMD" in
  post)            new_post ;;
  project)         new_project ;;
  talk|speaking)   new_talk ;;
  *)
    echo "Usage: ./scripts/new.sh <post|project|talk> [--flag value ...]"
    echo "Flags skip the matching prompt. See the header of this script for examples."
    [ -n "$CMD" ] && exit 1 || exit 0
    ;;
esac
