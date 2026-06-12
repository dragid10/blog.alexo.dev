# CLAUDE.md

Guidance for AI coding agents working in this repository.

## Overview

Alex Oladele's personal site at alexo.dev — **Astro 6 (AstroPaper theme) + TinaCMS 3**, deployed
on Vercel (Cloudflare-proxied). Includes a link-in-bio home page, blog, speaker portfolio,
project showcase, and resume. Posts are plain markdown in `src/content/posts/`,
editable from anywhere via git or the Tina visual editor at `/admin`.

Note: `CLAUDE.md` is a symlink to `WARP.md` — edit `WARP.md` directly.

`main` is branch-protected: all changes land via PR.

## Commands

```bash
yarn dev          # tinacms dev + astro dev → http://localhost:4321 (+ /admin, Tina GraphQL on :4001)
yarn build        # tinacms build && astro check && astro build && pagefind (needs Tina Cloud env vars)
yarn build:local  # same without tinacms build (no cloud creds needed)
yarn lint         # eslint
yarn format       # prettier --write

./scripts/new.sh post     # scaffold a draft post (prompts, or flags: --title --description --tags)
./scripts/new.sh project  # scaffold a project card (--title --description --repo --status ...)
./scripts/new.sh talk     # add a speaking engagement to speaking.yaml (--year --event --talk ...)
./scripts/publish.sh <draft.md> [--publish] [--pr]  # move an Obsidian draft into the site:
                          # strips date prefix, copies/rewrites images, lints wikilinks.
                          # Set BLOG_REPO env var to run it from outside the repo.
```

Node 24 via asdf (`.tool-versions`). Yarn classic 1.22.

## Architecture

- **Posts**: `src/content/posts/*.md` — schema in `src/content.config.ts`
  (title, description [required], pubDatetime, tags, ogImage…). Filename = URL slug
  (`/posts/<filename>/`). Drafts: `draft: true` or `_`-prefixed filename.
- **Projects**: `src/content/projects/*.md` — title, description, repo, demo, status,
  tags, featured, order. Archived projects are hidden from the page.
- **Speaking data**: `src/data/speaking.yaml` — engagements list under `engagements` key
  (object root required by Tina). Speaking page renders them grouped by year.
- **Pages**: `src/content/pages/` — about.md, bio-short.md, bio-long.md, resume.md.
  Home page is `src/pages/index.astro`. Speaking/projects/resume pages are in `src/pages/`.
- **Site config**: `astro-paper.config.ts` (title, author, socials, features).
- **Tina**: `tina/config.ts` + `tina/collection/` (post.ts, project.ts, speaking.ts)
  mirror the Astro schemas — keep them in sync when changing schemas.
  `tina/__generated__/` is gitignored, regenerated on build.
- **Domains**: `alexo.dev` is canonical (`site.url`). `blog.alexo.dev` and
  `www.alexo.dev` are attached to the same Vercel project and 301/308 to the apex
  via host-conditioned rules in `vercel.json`. Cloudflare proxies the zone; the
  apex is a flattened CNAME to Vercel.
- **Redirects + headers**: `vercel.json` — host redirects (blog/www → apex),
  Ghost-era and Jekyll-era path 301s, cache headers (immutable for hashed assets),
  security headers (HSTS, nosniff, etc.), and `ignoreCommand` to skip rebuilds on
  non-site file changes.
- **Images**: `public/assets/uploads/` (referenced as `/assets/uploads/...`).
  Headshots in `public/` root and `public/assets/uploads/speaking/`.
  `public/content/images/` is the old Ghost image tree kept so legacy hotlinks
  resolve forever — do not delete or "clean up".
- **Nav**: Home, Blog (route stays `/posts/`), Speaking, Projects, About (text
  links) + Search, Theme toggle (icon buttons). Tags and Archives pages exist but
  are not in the nav. Nav labels live in `src/i18n/lang/en.ts`.
- **Scripts**: `scripts/new.sh` (scaffold post/project/talk) and
  `scripts/publish.sh` (import an Obsidian draft; honors `BLOG_REPO` env var).
  Plain bash, no dependencies, flags documented in each file's header.
- **Commit graph**: `src/components/CommitGraph.astro` — client-side fetch from
  jogruber API, theme-aware colors. Uses `astro:page-load` event to re-init after
  SPA navigation (Astro ClientRouter pattern).
- GA4: gtag in `src/layouts/Layout.astro` (G-08Y6JZGV0F).

## Configurable things

### Font

The site font is configured in `astro.config.ts` under the `fonts` array. To change it:

1. Update `name` to any Google Fonts name (e.g. `"Inter"`, `"IBM Plex Sans"`, `"JetBrains Mono"`)
2. Update `cssVariable` to match (e.g. `"--font-inter"`)
3. Update `fallbacks` (e.g. `["sans-serif"]` or `["monospace"]`)
4. Update the same variable name in three other places:
   - `src/styles/theme.css` — the `--font-app` value
   - `src/layouts/Layout.astro` — the `<Font cssVariable="...">` prop
   - `src/pages/og.png.ts` and `src/pages/posts/[...slug]/index.png.ts` — the `fontData["..."]` key

### Site title, description, socials

All in `astro-paper.config.ts`. Socials need a matching SVG icon in `src/assets/icons/socials/` (Tabler Icons format, 24x24, stroke-based).

### Speaking engagements

`src/data/speaking.yaml` — add new entries under `engagements`. The speaking page renders them automatically, grouped by year descending.

### Projects

One markdown file per project in `src/content/projects/`. Schema: title, description, repo, demo, status, tags, featured, order. Archived projects are hidden from the page.

## Gotchas (hard-won, do not relearn)

- `@tinacms/cli` hoists vite 4 / zod 3 to root with yarn 1. Hence: Tailwind runs
  via `@tailwindcss/postcss` (NOT `@tailwindcss/vite`), and `zod@^4` is a direct
  devDependency so Astro's prerender resolves zod 4 at the root. Don't "clean up"
  either of these.
- `tsconfig.json` excludes `public/admin`, `tina/__generated__`, `vendor` —
  `astro check` OOMs or errors on generated/vendored files otherwise.
- Tina Cloud env vars on Vercel are type "sensitive" (`vercel env pull` shows them
  empty — expected; builds get real values).
- Local Tina codegen without cloud creds: `npx tinacms build --local --skip-cloud-checks --skip-indexing`.
- **Tina lock file after schema changes**: `tina/tina-lock.json` must be rebuilt
  when collections change. The cloud build needs creds we don't have locally.
  Workaround: run local tina build, then rebuild the lock from generated files:
  `node -e "const s=require('./tina/__generated__/_schema.json');const g=require('./tina/__generated__/_graphql.json');const l=require('./tina/__generated__/_lookup.json');require('fs').writeFileSync('tina/tina-lock.json',JSON.stringify({schema:s,lookup:l,graphql:g}))"`
  Then commit and push. After pushing, refresh the branch at app.tina.io → Branches.
- Don't use `text-muted` for text that needs to be readable (descriptions, subtitles,
  captions). Use `opacity-75` or `opacity-60` instead — `text-muted` is too low
  contrast in both themes.
- **Vercel redirect sources**: `/:path*` does NOT match `/` or any path with a
  trailing slash (Astro's canonical URL style). Use `/:path(.*)` for catch-alls
  and `:slug(.*)` for prefix matches, with `:path` / `:slug` in the destination.
- `main` is branch-protected (ruleset "Lock Main branch"), which blocks Tina
  `/admin` saves (PUT errors). DECIDED 2026-06: leave it that way. Editorial
  Workflow needs a business plan and a protection bypass for the Tina app is a
  security risk Alex rejected. Content edits go through Obsidian/scripts/PRs;
  do not "fix" Tina saves by weakening the ruleset.
- Pre-commit hooks (`pre-commit install` once): gitleaks, 2MB file guard
  (`public/content/images/` exempt), yaml/json checks, whitespace fixers. The
  whitespace fixer rewrites `tina/tina-lock.json` trailing newline — harmless.
