# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal blog site built with Jekyll (static site generator) and TinaCMS (headless CMS), using the Minimal Mistakes theme. The blog is deployed on Vercel and uses asdf for version management.

## Tech Stack

- **Jekyll** 4.3.3 - Static site generator (Ruby-based)
- **TinaCMS** 3.2.0 - Headless CMS for content management
- **Minimal Mistakes** - Jekyll theme
- **Ruby** 3.1.3 (managed via asdf)
- **Node.js** 22.21.1 (managed via asdf)
- **Yarn** - Node.js package manager

## Common Development Commands

### Initial Setup
```bash
# Install asdf plugins (first time only)
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Install language runtimes
asdf install

# Install dependencies
yarn install
bundle install
```

### Development Server
```bash
# Clean build artifacts and start dev server with live reload
yarn clean && yarn dev

# Or manually start Jekyll with TinaCMS
tinacms dev -c 'bundle exec jekyll serve --livereload'

# Just Jekyll without TinaCMS
bundle exec jekyll serve --livereload

# Clean build artifacts only
yarn clean  # or: jekyll clean
```

The development server runs at http://localhost:4000

### Production Build
```bash
# Build both TinaCMS admin panel and Jekyll site
yarn build

# Or step-by-step:
tinacms build    # Builds admin panel to /admin
jekyll build     # Builds site to /_site
```

## Architecture & Code Structure

### Content Management Flow

**TinaCMS → Jekyll → Static Site**

1. **TinaCMS** provides a visual editor at `/admin` for managing content
2. **Content is stored** as markdown files with YAML frontmatter in `_articles/` (Jekyll collection)
3. **Jekyll** processes these files and generates static HTML in `_site/`

### Key Directories

- `_articles/` - Blog articles as a Jekyll collection (format: `title_with_underscores.md`)
- `_pages/` - Static pages (posts list, tags, sitemap)
- `tina/` - TinaCMS configuration and schema definitions
  - `tina/config.ts` - Main TinaCMS configuration
  - `tina/collection/post.ts` - Article schema definition (points to `_articles/` directory)
  - `tina/collection/author.ts` - Author content model schema
- `content/authors/` - Author profiles (referenced by articles)
- `admin/` - Generated TinaCMS admin interface (built by `tinacms build`)
- `assets/uploads/` - Media files uploaded through TinaCMS
- `_data/` - Jekyll data files
- `_includes/` - Reusable template partials
- `_layouts/` - Jekyll layout templates
- `_config.yml` - Jekyll configuration

### Article Naming Convention

Articles use underscore-separated filenames WITHOUT date prefixes: `my_article_title.md`

TinaCMS automatically generates filenames from the title via the `slugify` function in `tina/collection/post.ts`, which converts spaces to underscores and lowercases the text.

### Article Frontmatter Structure

```yaml
---
title: "Article Title"
date: 2025-03-29  # Can be YYYY-MM-DD format
updated: 2025-03-30  # Optional
tags:
  - tag1
  - tag2
author: content/authors/Alex-Oladele.md
excerpt: "Brief description for SEO and previews"  # Optional
header:
  og_image: /assets/uploads/image.png  # Optional
---
```

### TinaCMS Content Collections

**Post Collection** (`tina/collection/post.ts`):
- Manages blog articles in `_articles/` directory
- Fields: title, date, updated, tags, author (reference), body (rich-text)
- Auto-generates filenames using lowercase + underscores (NO date prefix)
- Path in config: `path: "_articles"`

**Author Collection** (`tina/collection/author.ts`):
- Manages author profiles in `content/authors/`
- Fields: name, avatar
- Referenced by articles via the `author` field

### Jekyll Configuration

Key settings in `_config.yml`:
- Theme: `minimal-mistakes-jekyll` with "dark" skin
- **Collections**: Uses `_articles` collection (not traditional `_posts`)
  - Permalink for articles: `/:title/`
  - Articles use `single` layout with wide classes
- Pagination: 5 posts per page
- Timezone: America/New_York
- Markdown processor: kramdown
- Syntax highlighter: rouge
- Search: Enabled with Lunr

## Working with Content

### Creating New Articles

**Via TinaCMS (Recommended):**
1. Start dev server: `yarn dev`
2. Navigate to http://localhost:4000/admin
3. Create new article with visual editor
4. TinaCMS handles filename generation automatically (converts title to lowercase with underscores)

**Manually:**
1. Create file in `_articles/` with underscore-separated naming (e.g., `my_new_article.md`)
2. Add required frontmatter (title, date, author)
3. Write content in Markdown

### Editing Existing Articles

Edit markdown files directly in `_articles/` or use TinaCMS admin interface at `/admin` during development.

## Important Guidelines for AI Agents

When working in this repository:

1. **Content Location**: Articles are in `_articles/` directory (NOT `_posts/`)
2. **File Naming Convention**: Use underscore-separated filenames WITHOUT date prefixes (e.g., `my_article_title.md`, not `YYYY-MM-DD-title.md`)
3. **TinaCMS Schema**: Respect the schema definitions in `tina/collection/post.ts` when modifying content structure
4. **Package Manager**: Use `yarn` (not `npm`) for Node.js package management
5. **Jekyll Commands**: Always prefix Jekyll commands with `bundle exec` (e.g., `bundle exec jekyll serve`)
6. **Hybrid Project**: This is a Ruby + Node.js hybrid project (Jekyll + TinaCMS), requiring both ecosystems
7. **Container Runtime**: Prefer `podman` over `docker` when available on this system

## Environment Variables

TinaCMS requires these environment variables (typically in Vercel):
- `NEXT_PUBLIC_TINA_CLIENT_ID` - TinaCMS client ID
- `TINA_TOKEN` - TinaCMS authentication token
- `TINA_SEARCH_TOKEN` - TinaCMS search indexing token

## Deployment

Site is deployed on Vercel:
- Production URL: https://blog.alexo.dev
- Auto-deploys from `main` branch (or configured branch)
- Build command: `yarn build`
- Output directory: `_site/`

## Version Management

This project uses **asdf** for managing Ruby and Node.js versions. Version specifications are in `.tool-versions`:
- Ruby 3.1.3
- Node.js 22.21.1

Always use `asdf install` to ensure correct versions are installed.

## Jekyll Plugins Used

- jekyll-feed - RSS feed generation
- jekyll-gist - GitHub Gist embedding
- jekyll-seo-tag - SEO meta tags
- jekyll-include-cache - Performance optimization
- jekyll-sitemap - XML sitemap generation
- jekyll-paginate - Post pagination

## Theme Customization

The site uses Minimal Mistakes theme. Theme settings and overrides are in `_config.yml`:
- Skin: "dark"
- Author profile disabled on articles
- Wide layout for articles
- Search enabled with Lunr
- Google Analytics configured (tracking ID: G-08Y6JZGV0F)
- Social links in footer: Bluesky, Mastodon, GitHub, LinkedIn, Instagram, Threads

## Docker Support

A `Dockerfile.dev` is available for containerized development:
- Based on Ruby 3.1.3 with Node.js 20.x
- Installs both Ruby (bundle) and Node.js (yarn) dependencies
- Exposes port 4000
- Default command: `yarn dev`

```bash
# Build and run with Docker/Podman
podman build -f Dockerfile.dev -t blog-dev .
podman run -p 4000:4000 -v $(pwd):/app blog-dev
```

**Note**: Prefer `podman` over `docker` when available on this system.
