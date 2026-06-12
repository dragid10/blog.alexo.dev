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
- **Redirects + headers**: `vercel.json` — legacy URL 301s, cache headers (immutable
  for hashed assets), security headers (HSTS, nosniff, etc.), and `ignoreCommand`
  to skip rebuilds on non-site file changes.
- **Images**: `public/assets/uploads/` (referenced as `/assets/uploads/...`).
  Headshots in `public/` root and `public/assets/uploads/speaking/`.
- **Nav**: Home, Posts, Speaking, Projects, About (text links) + Search, Theme toggle
  (icon buttons). Tags and Archives pages exist but are not in the nav.
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
