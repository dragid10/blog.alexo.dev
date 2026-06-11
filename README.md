# blog.alexo.dev

Alex's blog — random thoughts on programming, homelab, and productivity.

Built with [Astro](https://astro.build) ([AstroPaper](https://github.com/satnaing/astro-paper) theme)
and [TinaCMS](https://tina.io), deployed on Vercel. Posts are plain markdown —
**pushing to `main` publishes automatically.**

## Writing a post (Obsidian workflow)

1. Write the post in Obsidian as a normal markdown note.
2. Add this front matter at the top (make it an Obsidian template for one-keystroke reuse):

   ```yaml
   ---
   title: "My Post Title"
   description: "One or two sentences — required, shows up in cards and SEO."
   pubDatetime: 2026-06-11T12:00:00Z
   tags:
     - Programming
   draft: false
   ---
   ```

3. Save/copy the file into `src/content/posts/` in this repo.
   **The filename becomes the URL**: `my-cool-post.md` → `blog.alexo.dev/posts/my-cool-post/`
   (use lowercase-with-hyphens).
4. Images: drop them in `public/assets/uploads/<post-name>/` and reference them as
   `![alt](/assets/uploads/<post-name>/pic.png)`.
5. Publish:

   ```bash
   git add . && git commit -m "Post: my cool post" && git push
   ```

   Vercel builds and deploys in ~2 minutes. Done.

Tips:
- Not ready to publish? Set `draft: true` (or prefix the filename with `_`).
- The [Obsidian Git plugin](https://github.com/Vinzent03/obsidian-git) can automate
  step 5 if your vault folder is (or contains) this repo.

## Other ways to publish

- **Tina editor**: blog.alexo.dev/admin — visual editing in the browser from any device;
  saves commit straight to the repo.
- **GitHub web editor**: edit/create files in `src/content/posts/` directly on github.com.

## Local development

```bash
asdf install      # Node 24
yarn install
yarn dev          # localhost:4321 (+ /admin)
```

See `CLAUDE.md` for architecture notes and build gotchas.
