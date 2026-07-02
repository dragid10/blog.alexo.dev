#!/usr/bin/env bash
# publish.sh — Move an Obsidian draft into the blog repo and prepare it for deploy.
#
# Handles: date-prefix stripping, image copying/path rewriting, and
# warnings about wikilinks, missing descriptions, or Templater leftovers.
# Optionally flips draft→published and opens a PR.
#
# See --help for full usage.
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
  BLOG_REPO_PATH         Path to your blog.alexo.dev checkout
                         (default: inferred from script location)
  OBSIDIAN_POSTS_PATH    Path to your Obsidian blog posts folder
                         (no default — set in your shell config)
EOF
}

# ---------------------------------------------------------------------------
# Configuration: locate the blog repo
# ---------------------------------------------------------------------------
ORIGINAL_WORKING_DIR="$(pwd)"
BLOG_REPO="${BLOG_REPO_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"

if [ ! -d "$BLOG_REPO/src/content/posts" ]; then
  echo "Not a blog repo: $BLOG_REPO" >&2
  echo "Set BLOG_REPO_PATH to your blog.alexo.dev checkout, e.g.:" >&2
  echo "  export BLOG_REPO_PATH=\"\$HOME/coding/alexo-website/blog.alexo.dev\"" >&2
  exit 1
fi
cd "$BLOG_REPO"

REPO_POSTS_DIR="src/content/posts"
IMAGE_UPLOADS_DIR="public/assets/uploads"
OBSIDIAN_POSTS_PATH="${OBSIDIAN_POSTS_PATH:-}"

# Check if gum is available for interactive prompts
HAS_GUM=""
command -v gum &>/dev/null && [ -t 0 ] && HAS_GUM="y"

# ---------------------------------------------------------------------------
# Parse command-line flags
# ---------------------------------------------------------------------------
SOURCE_FILE=""
URL_SLUG=""
SHOULD_PUBLISH=""
SHOULD_CREATE_PR=""
FORCE_OVERWRITE=""

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --slug)    URL_SLUG="$2"; shift 2 ;;
    --publish) SHOULD_PUBLISH="y"; shift ;;
    --pr)      SHOULD_CREATE_PR="y"; SHOULD_PUBLISH="y"; shift ;;
    --force)   FORCE_OVERWRITE="y"; shift ;;
    -*)        echo "Unknown flag: $1" >&2; echo "Run ./scripts/publish.sh --help for usage." >&2; exit 1 ;;
    *)         SOURCE_FILE="$1"; shift ;;
  esac
done

# If the source path is relative, resolve it against the directory the user ran from
if [ -n "$SOURCE_FILE" ] && [ ! -f "$SOURCE_FILE" ] && [ -f "$ORIGINAL_WORKING_DIR/$SOURCE_FILE" ]; then
  SOURCE_FILE="$ORIGINAL_WORKING_DIR/$SOURCE_FILE"
fi

# ---------------------------------------------------------------------------
# Interactive draft picker (when no file argument is given)
# ---------------------------------------------------------------------------
if [ -z "$SOURCE_FILE" ] && [ -n "$HAS_GUM" ]; then
  declare -a draft_file_paths=()
  declare -a draft_display_labels=()

  # Collect Obsidian drafts (newest first by modification time)
  if [ -n "$OBSIDIAN_POSTS_PATH" ] && [ -d "$OBSIDIAN_POSTS_PATH" ]; then
    while IFS= read -r file; do
      [ -z "$file" ] && continue
      draft_file_paths+=("$file")
      draft_display_labels+=("[obsidian]  $(basename "$file" .md)")
    done < <(ls -t "$OBSIDIAN_POSTS_PATH"/*.md 2>/dev/null)
  fi

  # Collect repo drafts (only files with draft: true, newest first)
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    grep -q '^draft: true' "$file" || continue
    draft_file_paths+=("$file")
    draft_display_labels+=("[repo]      $(basename "$file" .md)")
  done < <(ls -t "$REPO_POSTS_DIR"/*.md 2>/dev/null)

  if [ ${#draft_file_paths[@]} -gt 0 ]; then
    chosen_label="$(printf '%s\n' "${draft_display_labels[@]}" | gum choose --header "Pick a draft to publish:")"
    for i in "${!draft_display_labels[@]}"; do
      if [ "${draft_display_labels[$i]}" = "$chosen_label" ]; then
        SOURCE_FILE="${draft_file_paths[$i]}"
        break
      fi
    done
  fi
fi

if [ -z "$SOURCE_FILE" ] || [ ! -f "$SOURCE_FILE" ]; then
  if [ -z "$SOURCE_FILE" ]; then
    echo "Missing required argument: <draft.md>" >&2
  else
    echo "File not found: $SOURCE_FILE" >&2
  fi
  echo "Run ./scripts/publish.sh --help for usage." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Determine slug and destination path
# ---------------------------------------------------------------------------
source_directory="$(cd "$(dirname "$SOURCE_FILE")" && pwd)"
source_basename="$(basename "$SOURCE_FILE" .md)"

# Strip a Jekyll/vault-style date prefix (e.g. "2025-03-12-my-post" → "my-post")
if [ -z "$URL_SLUG" ]; then
  URL_SLUG="$(printf '%s' "$source_basename" | sed -E 's/^[0-9]{4}-[0-9]{2}-[0-9]{2}-//')"
fi
destination_file="$REPO_POSTS_DIR/$URL_SLUG.md"

# ---------------------------------------------------------------------------
# Copy the draft into the repo (unless it's already there)
# ---------------------------------------------------------------------------
if [ "$source_directory/$source_basename.md" = "$(pwd)/$destination_file" ]; then
  : # Already in place with the right name — nothing to copy
elif [ -e "$destination_file" ] && [ -z "$FORCE_OVERWRITE" ]; then
  echo "Refusing to overwrite existing post: $destination_file (use --force to replace a stub)" >&2
  exit 1
else
  cp "$SOURCE_FILE" "$destination_file"
  # If the source was a plugin export sitting in posts/ under the wrong name, clean it up
  case "$source_directory/" in
    "$(pwd)/$REPO_POSTS_DIR/") rm "$SOURCE_FILE" ;;
  esac
fi

# ---------------------------------------------------------------------------
# Process images: copy local images into the site and rewrite paths
# ---------------------------------------------------------------------------

# Extract all markdown image references from the post
mapfile -t image_references < <(grep -oE '!\[[^]]*\]\([^)]+\)' "$destination_file" | sed -E 's/^!\[[^]]*\]\(([^)]+)\)$/\1/' | sort -u || true)

images_copied=0
for image_ref in "${image_references[@]:-}"; do
  [ -z "$image_ref" ] && continue
  case "$image_ref" in
    http://*|https://*)
      # Remote URL — leave unchanged
      continue ;;
    /assets/uploads/*)
      # Already a valid site path — no action needed
      continue ;;
    ../../../public/assets/uploads/*)
      # Markdown-export plugin output — rewrite to site-relative path
      rewritten_path="${image_ref#../../../public}"
      sed -i "s|]($image_ref)|]($rewritten_path)|g" "$destination_file"
      continue ;;
    /*)
      echo "WARN: absolute image path left as-is: $image_ref" ;;
    *)
      # Relative path (next to the draft file) — copy into the site
      decoded_path="${image_ref//%20/ }"
      if [ -f "$source_directory/$decoded_path" ]; then
        mkdir -p "$IMAGE_UPLOADS_DIR/$URL_SLUG"
        image_filename="$(basename "$decoded_path")"
        echo "  Copying image: $image_filename"
        cp "$source_directory/$decoded_path" "$IMAGE_UPLOADS_DIR/$URL_SLUG/$image_filename"
        if command -v magick &>/dev/null; then
          orig_width=$(magick identify -format '%w' "$IMAGE_UPLOADS_DIR/$URL_SLUG/$image_filename")
          if [ "$orig_width" -gt 600 ]; then
            magick "$IMAGE_UPLOADS_DIR/$URL_SLUG/$image_filename" -resize '600>' "$IMAGE_UPLOADS_DIR/$URL_SLUG/$image_filename"
            echo "    Resized: ${orig_width}px → 600px"
          fi
        fi
        rewritten_path="/assets/uploads/$URL_SLUG/$(printf '%s' "$image_filename" | sed 's/ /%20/g')"
        sed -i "s|]($image_ref)|]($rewritten_path)|g" "$destination_file"
        echo "    Rewrote path → $rewritten_path"
        images_copied=$((images_copied + 1))
      else
        echo "  WARN: image not found next to draft: $image_ref"
      fi ;;
  esac
done

# ---------------------------------------------------------------------------
# Optional: flip draft → published and update the publish timestamp
# ---------------------------------------------------------------------------
if [ -n "$SHOULD_PUBLISH" ]; then
  sed -i 's/^draft: true$/draft: false/' "$destination_file"
  sed -i "s/^pubDatetime: .*/pubDatetime: $(date -u +%Y-%m-%dT%H:%M:%SZ)/" "$destination_file"
fi

# ---------------------------------------------------------------------------
# Sanity checks: catch common issues before they break the build
# ---------------------------------------------------------------------------
problem_count=0
report_problem() { echo "PROBLEM: $1"; problem_count=$((problem_count + 1)); }

grep -qE '!\[\[|[^!]\[\[' "$destination_file" && report_problem "wikilinks/embeds remain (![[..]] or [[..]]) — Astro can't render them"
grep -q '<%' "$destination_file" && report_problem "Templater leftovers (<% .. %>) found"
grep -qE '^description: *("")? *$' "$destination_file" && report_problem "description is empty (required, used for SEO/OG)"
head -1 "$destination_file" | grep -q '^---$' || report_problem "no frontmatter block at top of file"
grep -q '^draft: true' "$destination_file" && echo "NOTE: still draft: true (use --publish to flip, or edit by hand)"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "Placed: $destination_file"
[ "$images_copied" -gt 0 ] && echo "Copied $images_copied image(s) → $IMAGE_UPLOADS_DIR/$URL_SLUG/"
echo "URL after deploy: /posts/$URL_SLUG/"

if [ "$problem_count" -gt 0 ]; then
  echo ""
  echo "$problem_count problem(s) above need fixing before this will build/render right."
  exit 1
fi

# ---------------------------------------------------------------------------
# Optional: create a branch, commit, push, and open a PR
# ---------------------------------------------------------------------------
if [ -n "$SHOULD_CREATE_PR" ]; then
  branch_name="post/$URL_SLUG"
  git checkout -b "$branch_name"
  git add "$destination_file"
  [ -d "$IMAGE_UPLOADS_DIR/$URL_SLUG" ] && git add "$IMAGE_UPLOADS_DIR/$URL_SLUG"
  if ! git commit -m "New post: $URL_SLUG"; then
    echo "Pre-commit hooks modified files, re-staging and retrying commit..."
    git add "$destination_file"
    [ -d "$IMAGE_UPLOADS_DIR/$URL_SLUG" ] && git add "$IMAGE_UPLOADS_DIR/$URL_SLUG"
    git commit -m "New post: $URL_SLUG"
  fi
  git push -u origin "$branch_name"
  gh pr create --fill
  echo ""
  echo "PR opened. Merge it and Vercel deploys automatically."
else
  echo ""
  echo "Next steps:"
  echo "  git checkout -b post/$URL_SLUG"
  echo "  git add $destination_file $IMAGE_UPLOADS_DIR/$URL_SLUG 2>/dev/null"
  echo "  git commit -m \"New post: $URL_SLUG\" && git push -u origin post/$URL_SLUG"
  echo "  gh pr create --fill   # then merge"
  echo "(or rerun with --pr to do all of that for you)"
fi
