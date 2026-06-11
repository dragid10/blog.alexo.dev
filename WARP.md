# CLAUDE.md

Guidance for AI coding agents working in this repository.

## Overview

Alex's blog at blog.alexo.dev — **Astro 6 (AstroPaper theme) + TinaCMS 3**, deployed
on Vercel (Cloudflare-proxied). Posts are plain markdown in `src/content/posts/`,
editable from anywhere via git or the Tina visual editor at `/admin`.
(Migrated from Jekyll + minimal-mistakes in June 2026.)

The main alexo.dev site (intro/resume) is separate — a Ghost instance on a
DigitalOcean droplet, not this repo.

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
- **Site config**: `astro-paper.config.ts` (title, author, socials, features).
- **Tina**: `tina/config.ts` + `tina/collection/post.ts` mirror the Astro schema —
  keep them in sync when changing post front matter. `tina/__generated__/` is
  gitignored, regenerated on build.
- **Pages**: about lives in `src/content/pages/about.md`; homepage hero text is in
  `src/pages/index.astro`.
- **Redirects**: `vercel.json` — legacy Jekyll-era URLs 301 to `/posts/<slug>/`,
  `/feed.xml` → `/rss.xml`. Also sets framework/buildCommand for Vercel.
- **Images**: `public/assets/uploads/` (referenced as `/assets/uploads/...`).
- GA4: gtag in `src/layouts/Layout.astro` (G-08Y6JZGV0F).

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
