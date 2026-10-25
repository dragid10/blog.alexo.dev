#!/usr/bin/env bash
# audit-projects.sh — Check each project card's status against its last commit.
#
# Rules (also in AGENTS.md):
#   active      a commit within the last 6 months
#   maintained  last commit 6 to 18 months ago
#   archived    no commit in over 18 months, or explicitly declared archived
#
# Commits by bots (Dependabot and similar) don't count.
#
# A card already marked "archived" is treated as explicitly declared and is
# never changed by this script. If such a card has a commit in the last 6
# months, it is reported as "archived but active again - unarchive?" but left
# as is. Cards with no repo to look up are skipped.
#
# Cards with a `repo:` URL are looked up automatically. For a card without
# one (e.g. a private repo that isn't linked from the site), add a line
# "<card-slug> <owner>/<repo>" to scripts/project-repos.local. That file is
# gitignored, so private repo names stay out of this public repository.
#
# Requires: gh (authenticated). Read-only unless --write is passed.
#
# Usage:
#   ./scripts/audit-projects.sh           # print a table; exit 1 if any card is out of date
#   ./scripts/audit-projects.sh --write   # also rewrite `status:` in the cards that differ
set -euo pipefail
cd "$(dirname "$0")/.."

PROJECTS_DIR="src/content/projects"
LOCAL_REPOS_FILE="scripts/project-repos.local"
WRITE=0

case "${1:-}" in
  "") ;;
  --write) WRITE=1 ;;
  -h | --help)
    sed -n '2,/^set -euo/{/^#/p}' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "unknown argument: $1 (try --help)" >&2
    exit 2
    ;;
esac

command -v gh >/dev/null || { echo "gh is required" >&2; exit 2; }

# Cutoff dates as YYYY-MM-DD; ISO dates compare correctly as strings.
# GNU date first, BSD/macOS date as the fallback.
date_months_ago() {
  date -u -d "$1 months ago" +%F 2>/dev/null || date -u -v-"$1"m +%F
}
ACTIVE_CUTOFF=$(date_months_ago 6)
MAINTAINED_CUTOFF=$(date_months_ago 18)

# frontmatter <file> <key> — print a top-level frontmatter value, unquoted.
frontmatter() {
  awk -v key="$2" '
    /^---$/ { n++; next }
    n == 1 && $0 ~ "^" key ":" {
      sub("^" key ":[ ]*", ""); gsub(/^"|"$/, ""); print; exit
    }' "$1"
}

# local_repo <slug> — look up an owner/repo in the gitignored override file.
local_repo() {
  [ -f "$LOCAL_REPOS_FILE" ] || return 0
  awk -v slug="$1" '$1 == slug { print $2; exit }' "$LOCAL_REPOS_FILE"
}

# last_commit_date <owner/repo> [path] — date of the newest non-bot commit among
# the latest 30, or empty.
last_commit_date() {
  local repo=$1 path=${2:-}
  local args=(-f per_page=30)
  [ -n "$path" ] && args+=(-f "path=$path")
  local out
  # --method GET is required: gh sends a POST whenever -f is used.
  out=$(gh api --method GET "repos/$repo/commits" "${args[@]}" --jq '[.[] | select((.author.type // "User") != "Bot" and ((.author.login // "") | endswith("[bot]") | not))][0].commit.committer.date[:10] // empty' 2>/dev/null) || return 0
  # Only accept a real date, so an error body can't pass as one.
  [[ "$out" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && echo "$out"
  return 0
}

stale=0
printf '%-32s %-11s %-11s %-12s %s\n' CARD STATUS LAST-COMMIT SHOULD-BE NOTE
for file in "$PROJECTS_DIR"/*.md; do
  slug=$(basename "$file" .md)
  status=$(frontmatter "$file" status)
  repo_url=$(frontmatter "$file" repo)

  repo="" path=""
  if [[ "$repo_url" =~ ^https://github\.com/([^/]+/[^/]+)(/tree/[^/]+/(.+))?/?$ ]]; then
    repo=${BASH_REMATCH[1]}
    path=${BASH_REMATCH[3]:-}
  else
    repo=$(local_repo "$slug")
  fi

  if [ "$status" = archived ]; then
    # Never changed here, but report a revived project so it can be unarchived by hand.
    last="" note="explicitly archived, left as is"
    if [ -n "$repo" ]; then
      last=$(last_commit_date "$repo" "$path")
      if [ -n "$last" ] && [[ "$last" > "$ACTIVE_CUTOFF" || "$last" == "$ACTIVE_CUTOFF" ]]; then
        note="archived but active again - unarchive?"
      fi
    fi
    printf '%-32s %-11s %-11s %-12s %s\n' "$slug" "$status" "${last:--}" archived "$note"
    continue
  fi
  if [ -z "$repo" ]; then
    printf '%-32s %-11s %-11s %-12s %s\n' "$slug" "$status" - - "skipped: no repo (see $LOCAL_REPOS_FILE)"
    continue
  fi

  last=$(last_commit_date "$repo" "$path")
  if [ -z "$last" ]; then
    printf '%-32s %-11s %-11s %-12s %s\n' "$slug" "$status" ? - "skipped: lookup failed"
    continue
  fi

  if [[ "$last" > "$ACTIVE_CUTOFF" || "$last" == "$ACTIVE_CUTOFF" ]]; then
    want=active
  elif [[ "$last" > "$MAINTAINED_CUTOFF" || "$last" == "$MAINTAINED_CUTOFF" ]]; then
    want=maintained
  else
    want=archived
  fi

  note=""
  if [ "$want" != "$status" ]; then
    stale=1
    note="-> change to $want"
    if [ "$WRITE" -eq 1 ]; then
      sed -i.bak -E "s/^status:.*/status: \"$want\"/" "$file" && rm -f "$file.bak"
      note="$note (written)"
    fi
  fi
  printf '%-32s %-11s %-11s %-12s %s\n' "$slug" "$status" "$last" "$want" "$note"
done

if [ "$stale" -eq 1 ] && [ "$WRITE" -eq 0 ]; then
  echo
  echo "Some cards are out of date. Re-run with --write to update them."
  exit 1
fi
