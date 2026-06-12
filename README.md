# alexo.dev

Alex's whole web presence: link-in-bio home page, blog, speaker portfolio,
project showcase, and resume.

Built with [Astro](https://astro.build) ([AstroPaper](https://github.com/satnaing/astro-paper) theme)
and [TinaCMS](https://tina.io), deployed on Vercel. All content is plain markdown/YAML.
`main` is branch-protected: **changes land via PR, and merging publishes automatically** (~2 min).

## Writing a blog post (Obsidian workflow)

1. Draft in Obsidian. The `astro-blog-post` Templater template scaffolds the
   front matter for you:

   ```yaml
   ---
   title: "My Post Title"
   description: "One or two sentences. Required, shows up in cards and SEO."
   pubDatetime: 2026-06-11T12:00:00Z
   tags:
     - Programming
   draft: true
   ---
   ```

2. Use standard markdown only. No `[[wikilinks]]` or `![[image]]` embeds.
   (The Obsidian *Markdown Export* plugin converts embeds and pulls attachments
   into the repo if you point its output at `src/content/posts`.)
3. Move it into the site:

   ```bash
   ./scripts/publish.sh ~/path/to/vault/blog/posts/my-draft.md --publish --pr
   ```

   This strips any date prefix off the filename (**the filename becomes the URL**:
   `my-cool-post.md` → `alexo.dev/posts/my-cool-post/`), copies referenced images
   into `public/assets/uploads/<slug>/`, rewrites their paths, and warns about
   anything Astro can't render. `--publish` flips `draft: false` and bumps the
   date; `--pr` opens the pull request for you. Merge it and you're live.

   To run it from outside the repo, set the env var once per machine:

   ```bash
   export BLOG_REPO="$HOME/coding/alexo-website/blog.alexo.dev"
   ```

Tips:
- Not ready to publish? Keep `draft: true` (or prefix the filename with `_`).
- Images by hand: `public/assets/uploads/<slug>/pic.png`, referenced as
  `![alt](/assets/uploads/<slug>/pic.png)`.

## Scaffolding new content

`./scripts/new.sh` creates correctly-shaped files for any content type
(prompts for anything you don't pass as a flag):

```bash
./scripts/new.sh post     # draft post in src/content/posts/
./scripts/new.sh project  # project card in src/content/projects/
./scripts/new.sh talk     # speaking engagement added to src/data/speaking.yaml
```

## Other ways to publish

- **GitHub web editor**: edit/create files in `src/content/` directly on github.com
  (it branches + opens a PR for you when the target branch is protected).
- **Tina editor** (`/admin`): currently view-only in practice — saves are blocked by
  branch protection on `main`, and that's intentional (Tina's PR-based Editorial
  Workflow is paywalled, and a protection bypass isn't worth the risk).

## Local development

```bash
asdf install        # Node 24
yarn install
pre-commit install  # gitleaks + hygiene hooks (one-time)
yarn dev            # localhost:4321 (+ /admin)
```

See `CLAUDE.md` for architecture notes and build gotchas.
