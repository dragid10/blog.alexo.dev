# Astro Migration Plan — blog.alexo.dev

## Why

The blog's whole point is **plain markdown, publishable from anywhere** (GitHub web
editor, Tina `/admin`, any git-synced editor). Jekyll delivers that but drags a Ruby
toolchain alongside the Node one Tina already needs, and Jekyll is in maintenance
mode (one release in ~18 months). Astro keeps the exact same git+markdown workflow
with a single Node toolchain and an active ecosystem. Decision made 2026-06-11
(see `../MODERNIZE_ALEXO_DEV.md` for the overall architecture: Ghost = intro site,
this repo = the blog).

## What must survive (inventory, verified)

- **8 articles** in `_articles/` — front matter: `title`, `date`, `tags`,
  `header.image` / `header.og_image`, sometimes `excerpt`, `author` ref
- **URLs**: old links must keep working. Decision (2026-06-11): **normalize slugs to
  lowercase-hyphen** and 301-redirect the old mixed-case/underscore URLs (full map below)
- **Feed** at `/feed.xml` (live, presumably has subscribers) — keep the path
- Sitemap, tag pages, full-text search (currently lunr), dark theme
- **GA4** analytics: `G-08Y6JZGV0F`
- **TinaCMS** editing at `/admin` (Tina Cloud; envs live in Vercel) — post + author collections
- **Images** under `assets/uploads/...` (~5.7 MB), referenced by absolute path in posts
- One post embeds a GitHub gist (`jekyll-gist` plugin) — needs manual conversion
- Hosting: Vercel (Cloudflare-proxied), repo deploys on push

Not used / can drop: comments, Ghost-style members, breadcrumbs, multiple authors
(single author: Alex).

## Target stack

| Concern | Choice |
|---------|--------|
| Framework | Astro ^6 with content collections (typed front matter) |
| Look | Start from **AstroPaper** theme (closest to current minimal-mistakes dark feel: dark mode, tags, search, RSS, SEO built in). Alternative: Astro Cactus, or hand-rolled minimal. |
| Search | Theme default (AstroPaper ships one); else **Pagefind** |
| RSS | `@astrojs/rss` aliased/redirected so `/feed.xml` keeps working |
| Sitemap | `@astrojs/sitemap` |
| CMS | TinaCMS ^3.9 + CLI ^2.4 (official Astro support) — same `/admin` workflow |
| Analytics | GA4 snippet in base layout (same `G-08Y6JZGV0F`) |
| Node | 24 LTS pinned in `.tool-versions` (drop the `ruby` pin when Jekyll is removed) |
| Hosting | Same Vercel project, framework preset switched to Astro |

## Phases

### Phase 0 — Branch + scaffold
- `git switch -c astro-migration` (keep repo + Vercel project + git history; Vercel
  preview deploys give us a staging URL for free)
- Scaffold AstroPaper into the repo root alongside the Jekyll files (they coexist
  until cleanup; Jekyll files are inert without `jekyll build`)
- Port site identity into the Astro config: title "Alex's blog", author, socials
  (GitHub `dragid10`, Twitter `wizkid_alex`), GA4 snippet in the base layout

### Phase 1 — Content port (the heart of it)
- Move `_articles/*.md` → `src/content/blog/` (theme's collection dir)
- Front matter mapping per post:
  | Jekyll | Astro (AstroPaper) |
  |--------|-------|
  | `title` (strip literal `**` in the pip-freeze post) | `title` |
  | `date` | `pubDatetime` |
  | `tags` | `tags` |
  | `excerpt` | `description` (write one for posts missing it — needed for SEO/cards) |
  | `header.image` | `ogImage` / hero image |
  | filename | explicit `slug` field — **normalized** (lowercase, hyphens; see map) |
  | `author` ref | drop (single-author site) |

- **Slug normalization map** (old path → new slug; old paths get 301s in Phase 2):

  | Old URL | New slug |
  |---------|----------|
  | `/avoid_pip_freeze/` | `avoid-pip-freeze` |
  | `/db2_on_mac/` | `db2-on-mac` |
  | `/vscode_on_truenas/` | `vscode-on-truenas` |
  | `/What_consistency_looks_like/` | `what-consistency-looks-like` |
  | `/Media_consumed_in_2023/` | `media-consumed-in-2023` |
  | `/Apple_rankings/` | `apple-rankings` |
  | `/i-created-a-tidbyt-app/` | `i-created-a-tidbyt-app` (already clean) |
  | `/my-ideal-todo-app/` | `my-ideal-todo-app` (already clean) |
- Convert the one gist embed to a code block or `<script src>` embed
- Copy `assets/uploads/**` → `public/assets/uploads/**` (in-post image paths then
  work unchanged)

### Phase 2 — Parity features + redirects
- Tag pages (theme built-in) — verify old tag names render
- RSS: theme outputs `/rss.xml`; add a redirect or static route so **`/feed.xml`**
  serves the feed too
- **301 redirects in `vercel.json`** for the 6 renamed slugs (map above) — Vercel
  path matching is exact/case-sensitive, so each old URL gets its own entry
- `/posts/` listing: exists in AstroPaper by default, same URL as the old Jekyll
  listing page — no action needed
- Sitemap, 404, dark mode default (current skin is "dark")

### Phase 3 — Tina rewire
- Bump `tinacms` → ^3.9, `@tinacms/cli` → ^2.4 (same majors as the other repo —
  known-good)
- Update `tina/config.ts`: post collection `path: "src/content/blog"`, fields
  matched to the new front matter schema (title, description, pubDatetime, tags,
  ogImage, slug); drop the author collection
- Scripts: `dev: tinacms dev -c "astro dev"`, `build: tinacms build && astro build`
- Verify `/admin` can create + edit a post that Astro then builds

### Phase 4 — Vercel cutover
- Update Vercel project: framework Astro, output `dist/`, build command from
  package.json; Tina env vars unchanged
- Merge `astro-migration` after the preview deploy checks out

### Phase 5 — Cleanup
- Remove Jekyll: `Gemfile*`, `_config.yml`, `_includes/`, `_layouts/`, `_pages/`,
  `_data/`, `_site/`, `index.html`, `Dockerfile.dev`, `assets/` (now in `public/`),
  `ruby` line in `.tool-versions`
- Update `README.md`, `CLAUDE.md`, `AGENTS.md`, `WARP.md` for the new stack
- Archive note in `../MODERNIZE_ALEXO_DEV.md`

## Verification checklist (before merging)

- [ ] All 8 new (normalized) URLs return 200 on the Vercel preview
- [ ] All 6 renamed old URLs 301 to their new slug (curl -I each)
- [ ] `/feed.xml` serves valid RSS (run through a validator)
- [ ] `/sitemap-index.xml` or `/sitemap.xml` present
- [ ] Tag pages render; post images load; code blocks highlighted
- [ ] Gist post content intact
- [ ] `/admin` Tina editing works end-to-end (create draft → see it in `astro dev`)
- [ ] GA4 requests fire on page load
- [ ] Dark mode default; Lighthouse ≥ 95 perf (Astro should crush this)

## Decisions for Alex

1. **Theme**: AstroPaper (recommended, closest match) vs Astro Cactus vs minimal custom?
2. Anything beyond the 8 articles worth porting (drafts elsewhere)?

Resolved: URLs normalized to lowercase-hyphen with 301s (2026-06-11); `/posts/`
listing survives automatically with AstroPaper.

## Status

- [x] Phase 0 — branch + scaffold (AstroPaper 6.1 / Astro 6.4; Node pin bumped to 24.16.0 — Tina's posthog dep needs ≥22.22)
- [x] Phase 1 — content port (8 posts converted, descriptions written for 5 that lacked excerpts; images in `public/assets/uploads`; the "gist" was a plain link — no conversion needed)
- [x] Phase 2 — parity (tags/archives/search/rss/sitemap/404 build; GA4 in Layout.astro; `vercel.json` has all 8 post redirects + `/feed.xml`→`/rss.xml`) — **NOTE: posts now live under `/posts/<slug>/` (AstroPaper convention), redirects updated accordingly**
- [x] Phase 3 — Tina rewire (post collection → `src/content/posts`, AstroPaper-schema fields; author collection dropped; codegen + dev mode verified)
- [ ] Phase 4 — Vercel cutover (push branch → preview deploy → update project settings: framework Astro, Node 24 → verify checklist → merge)
- [ ] Phase 5 — cleanup (remove Jekyll files + ruby pin, update README/CLAUDE.md/AGENTS.md/WARP.md)

### Build quirks worth knowing (all worked around, yarn-1 hoisting related)

- `@tailwindcss/vite` resolved tinacms's hoisted vite 4 → swapped to `@tailwindcss/postcss` (postcss.config.js)
- Astro's prerender resolves bare `zod` from root, where tinacms hoisted zod 3 → added direct devDep `zod@^4.4.3` to win the root slot (tinacms keeps nested zod 3)
- `astro check` OOM'd type-checking the 11MB Tina admin SPA → `public/admin`, `tina/__generated__`, `_site` added to tsconfig `exclude` (and `public/admin` gitignored)
- Local full build without Tina Cloud creds: `yarn build:local` (skips `tinacms build`); Tina codegen locally: `npx tinacms build --local --skip-cloud-checks --skip-indexing`
