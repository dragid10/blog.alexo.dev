
# blog.alexo.dev

![Vercel Deploy](https://therealsujitk-vercel-badge.vercel.app/?app=blog-alexo-dev&style=flat-square)

The code that hosts [Alex's blog](https://blog.alexo.dev)

## Tech Stack

Languages:

- **Ruby** 3.1.3 - [Bundler package manager](https://bundler.io/)
- **Node.js** 20.10.0 - [Yarn package manager](https://yarnpkg.com/)

Frameworks:

- [**Jekyll**](https://jekyllrb.com/) 4.3.3 - Static site generator
- [**TinaCMS**](https://tina.io/) 2.7.x - Headless CMS with visual editor

Deployment:

- [**asdf**](https://asdf-vm.com/) - Version manager for Ruby and Node.js
- [**Vercel**](https://vercel.com/) - Hosting platform

Site Theme:

- [**Minimal-Mistakes**](https://github.com/mmistakes/minimal-mistakes) - Jekyll theme (dark skin)

## Project Structure

This blog uses a custom architecture:

- **Content lives in `_articles/`** (Jekyll collection, not traditional `_posts/`)
- **Article filenames use underscores**: `my_article_title.md` (no date prefix)
- **TinaCMS admin panel** at `/admin` for visual content editing
- **Static output** generated to `_site/`

For detailed architecture and development guidelines, see [WARP.md](./WARP.md).

## Run Locally

### Prerequisites

Install [asdf version manager](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf) if you haven't already.

### Setup

1. Clone the project:

    ```bash
    git clone https://github.com/dragid10/blog.alexo.dev
    cd blog.alexo.dev
    ```

2. Install asdf plugins:

    ```bash
    asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    ```

3. Install dependencies:

    ```bash
    asdf install          # Installs Ruby 3.1.3 & Node.js 20.10.0
    yarn install          # Node.js dependencies
    bundle install        # Ruby dependencies
    ```

4. Start the development server:

    ```bash
    yarn clean && yarn dev
    ```

5. Access the site:
    - **Blog**: http://localhost:4000
    - **TinaCMS Admin**: http://localhost:4000/admin

### Alternative: Docker/Podman

```bash
podman build -f Dockerfile.dev -t blog-dev .
podman run -p 4000:4000 -v $(pwd):/app blog-dev
```

## Available Commands

```bash
yarn dev      # Start Jekyll + TinaCMS with live reload
yarn build    # Build TinaCMS admin panel + Jekyll site
yarn clean    # Clean build artifacts

# Or use Jekyll directly:
bundle exec jekyll serve --livereload
bundle exec jekyll build
```

## Creating Content

### Via TinaCMS (Recommended)

1. Start dev server: `yarn dev`
2. Navigate to http://localhost:4000/admin
3. Create/edit articles with the visual editor
4. TinaCMS automatically generates filenames from titles

### Manually

Create markdown files in `_articles/` with underscore-separated names (e.g., `my_new_article.md`).

Required frontmatter:
```yaml
---
title: "Article Title"
date: 2025-03-29
author: content/authors/Alex-Oladele.md
tags:
  - tag1
---
```

## License

[MIT](https://choosealicense.com/licenses/mit/)
