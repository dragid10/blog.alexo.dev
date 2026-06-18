#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
publish.sh - move an Obsidian draft into the site and get it ready to ship

Usage:
  ./scripts/publish.sh <draft.md> [flags]

Examples:
  ./scripts/publish.sh "$OBSIDIAN_POSTS_PATH/my-post.md"
  ./scripts/publish.sh my-post.md --publish
  ./scripts/publish.sh my-post.md --publish --pr

Arguments:
  <draft.md>             Path to an Obsidian draft or a file already in
                         src/content/posts/ (via the markdown-export plugin)

Flags:
  --slug SLUG            Override the URL slug (default: filename minus date prefix)
  --publish              Set draft: false and bump pubDatetime to now
  --pr                   Create a branch, commit, push, and open a PR
  --force                Overwrite an existing post file
  -h, --help             Show this help

Handles: date-prefix stripping, copying/rewriting image paths, and
warning about wikilinks, missing descriptions, or Templater leftovers.

Environment:
  BLOG_REPO_PATH              Path to your blog.alexo.dev checkout
                         (default: inferred from script location)
EOF
}

ORIG_PWD="$(pwd)"
REPO="${BLOG_REPO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
if [ ! -d "$REPO/src/content/posts" ]; then
  echo "Not a blog repo: $REPO" >&2
  echo "Set BLOG_REPO_PATH to your blog.alexo.dev checkout, e.g.:" >&2
  echo "  export BLOG_REPO_PATH=\"\$HOME/coding/alexo-website/blog.alexo.dev\"" >&2
  exit 1
fi
cd "$REPO"

POSTS_DIR="src/content/posts"
UPLOADS_DIR="public/assets/uploads"
OBSIDIAN_POSTS_PATH="${OBSIDIAN_POSTS_PATH:-}"

HAS_GUM=""
command -v gum &>/dev/null && [ -t 0 ] && HAS_GUM="y"

SRC="" SLUG="" PUBLISH="" MAKE_PR="" FORCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --slug)    SLUG="$2"; shift 2 ;;
    --publish) PUBLISH="y"; shift ;;
    --pr)      MAKE_PR="y"; PUBLISH="y"; shift ;;
    --force)   FORCE="y"; shift ;;
    -*)        echo "Unknown flag: $1" >&2; echo "Run ./scripts/publish.sh --help for usage." >&2; exit 1 ;;
    *)         SRC="$1"; shift ;;
  esac
done

# resolve a relative draft path against the directory the user ran from
if [ -n "$SRC" ] && [ ! -f "$SRC" ] && [ -f "$ORIG_PWD/$SRC" ]; then
  SRC="$ORIG_PWD/$SRC"
fi

# no file given - if gum is available, pick a draft interactively
if [ -z "$SRC" ] && [ -n "$HAS_GUM" ]; then
  declare -a draft_files=()
  declare -a draft_labels=()

  # collect Obsidian drafts (newest first)
  if [ -n "$OBSIDIAN_POSTS_PATH" ] && [ -d "$OBSIDIAN_POSTS_PATH" ]; then
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      draft_files+=("$f")
      draft_labels+=("[obsidian]  $(basename "$f" .md)")
    done < <(ls -t "$OBSIDIAN_POSTS_PATH"/*.md 2>/dev/null)
  fi

  # collect repo drafts (only those with draft: true, newest first)
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    grep -q '^draft: true' "$f" || continue
    draft_files+=("$f")
    draft_labels+=("[repo]      $(basename "$f" .md)")
  done < <(ls -t "$POSTS_DIR"/*.md 2>/dev/null)

  if [ ${#draft_files[@]} -gt 0 ]; then
    CHOSEN_LABEL="$(printf '%s\n' "${draft_labels[@]}" | gum choose --header "Pick a draft to publish:")"
    for i in "${!draft_labels[@]}"; do
      if [ "${draft_labels[$i]}" = "$CHOSEN_LABEL" ]; then
        SRC="${draft_files[$i]}"
        break
      fi
    done
  fi
fi

if [ -z "$SRC" ] || [ ! -f "$SRC" ]; then
  if [ -z "$SRC" ]; then
    echo "Missing required argument: <draft.md>" >&2
  else
    echo "File not found: $SRC" >&2
  fi
  echo "Run ./scripts/publish.sh --help for usage." >&2
  exit 1
fi

SRC_DIR="$(cd "$(dirname "$SRC")" && pwd)"
BASE="$(basename "$SRC" .md)"
# strip a Jekyll/vault-style date prefix: 2025-03-12-foo -> foo
if [ -z "$SLUG" ]; then
  SLUG="$(printf '%s' "$BASE" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')"
fi
DEST="$POSTS_DIR/$SLUG.md"

if [ "$SRC_DIR/$BASE.md" = "$(pwd)/$DEST" ]; then
  : # already in place with the right name
elif [ -e "$DEST" ] && [ -z "$FORCE" ]; then
  echo "Refusing to overwrite existing post: $DEST (use --force to replace a stub)" >&2
  exit 1
else
  cp "$SRC" "$DEST"
  # if the source was a plugin export sitting in posts/ under the wrong name, tidy it
  case "$SRC_DIR/" in
    "$(pwd)/$POSTS_DIR/") rm "$SRC" ;;
  esac
fi

# --- images -----------------------------------------------------------------
mapfile -t IMAGE_REFS < <(grep -oE '!\[[^]]*\]\([^)]+\)' "$DEST" | sed -E 's/^!\[[^]]*\]\(([^)]+)\)$/\1/' | sort -u || true)

copied=0
for ref in "${IMAGE_REFS[@]:-}"; do
  [ -z "$ref" ] && continue
  case "$ref" in
    http://*|https://*) continue ;;                # remote, leave alone
    /assets/uploads/*) continue ;;                 # already a site path
    ../../../public/assets/uploads/*)              # markdown-export plugin output
      new_ref="${ref#../../../public}"
      sed -i "s|]($ref)|]($new_ref)|g" "$DEST"
      continue ;;
    /*) echo "WARN: absolute image path left as-is: $ref" ;;
    *)                                             # relative to the draft -> copy it in
      decoded="${ref//%20/ }"
      if [ -f "$SRC_DIR/$decoded" ]; then
        mkdir -p "$UPLOADS_DIR/$SLUG"
        img_name="$(basename "$decoded")"
        cp "$SRC_DIR/$decoded" "$UPLOADS_DIR/$SLUG/$img_name"
        new_ref="/assets/uploads/$SLUG/$(printf '%s' "$img_name" | sed 's/ /%20/g')"
        sed -i "s|]($ref)|]($new_ref)|g" "$DEST"
        copied=$((copied + 1))
      else
        echo "WARN: image not found next to draft: $ref"
      fi ;;
  esac
done

# --- optional publish flip ----------------------------------------------------
if [ -n "$PUBLISH" ]; then
  sed -i 's/^draft: true$/draft: false/' "$DEST"
  sed -i "s/^pubDatetime: .*/pubDatetime: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$DEST"
fi

# --- sanity checks ------------------------------------------------------------
problems=0
flag() { echo "PROBLEM: $1"; problems=$((problems + 1)); }

grep -qE '!\[\[|[^!]\[\[' "$DEST" && flag "wikilinks/embeds remain (![[..]] or [[..]]) - Astro can't render them"
grep -q '<%' "$DEST" && flag "Templater leftovers (<% .. %>) found"
grep -qE '^description: *("")? *$' "$DEST" && flag "description is empty (required, used for SEO/OG)"
head -1 "$DEST" | grep -q '^---$' || flag "no frontmatter block at top of file"
grep -q '^draft: true' "$DEST" && echo "NOTE: still draft: true (use --publish to flip, or edit by hand)"

# --- report -------------------------------------------------------------------
echo ""
echo "Placed: $DEST"
[ "$copied" -gt 0 ] && echo "Copied $copied image(s) -> $UPLOADS_DIR/$SLUG/"
echo "URL after deploy: /posts/$SLUG/"

if [ "$problems" -gt 0 ]; then
  echo ""
  echo "$problems problem(s) above need fixing before this will build/render right."
  exit 1
fi

# --- optional PR ----------------------------------------------------------------
if [ -n "$MAKE_PR" ]; then
  branch="post/$SLUG"
  git checkout -b "$branch"
  git add "$DEST"
  [ -d "$UPLOADS_DIR/$SLUG" ] && git add "$UPLOADS_DIR/$SLUG"
  git commit -m "New post: $SLUG"
  git push -u origin "$branch"
  gh pr create --fill
  echo ""
  echo "PR opened. Merge it and Vercel deploys automatically."
else
  echo ""
  echo "Next steps:"
  echo "  git checkout -b post/$SLUG"
  echo "  git add $DEST $UPLOADS_DIR/$SLUG 2>/dev/null"
  echo "  git commit -m \"New post: $SLUG\" && git push -u origin post/$SLUG"
  echo "  gh pr create --fill   # then merge"
  echo "(or rerun with --pr to do all of that for you)"
fi
