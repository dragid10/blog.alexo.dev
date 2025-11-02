# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a personal blog site built with Jekyll (static site generator) and TinaCMS (headless CMS), using the Minimal Mistakes theme. The blog is deployed on Vercel and uses asdf for version management.

## Tech Stack

- **Jekyll** 4.3.3 - Static site generator (Ruby-based)
- **TinaCMS** 1.5.x - Headless CMS for content management
- **Minimal Mistakes** - Jekyll theme
- **Ruby** 3.1.3 (managed via asdf)
- **Node.js** 20.10.0 (managed via asdf)
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
2. **Content is stored** as markdown files with YAML frontmatter in `_posts/`
3. **Jekyll** processes these files and generates static HTML in `_site/`

### Key Directories

- `_posts/` - Blog post markdown files (format: `YYYY-MM-DD-title.md`)
- `_pages/` - Static pages (posts list, tags, sitemap)
- `tina/` - TinaCMS configuration and schema definitions
  - `tina/config.ts` - Main TinaCMS configuration
  - `tina/collection/post.ts` - Post content model schema
  - `tina/collection/author.ts` - Author content model schema
- `content/authors/` - Author profiles (referenced by posts)
- `admin/` - Generated TinaCMS admin interface (built by `tinacms build`)
- `assets/uploads/` - Media files uploaded through TinaCMS
- `_data/` - Jekyll data files
- `_includes/` - Reusable template partials
- `_config.yml` - Jekyll configuration

### Post Naming Convention

Posts follow Jekyll's strict naming format: `YYYY-MM-DD-title.md`

TinaCMS automatically generates filenames using this pattern via the `slugify` function in `tina/collection/post.ts`.

### Post Frontmatter Structure

```yaml
---
title: "Post Title"
date: 2024-02-07T00:00:00.000Z
updated: 2024-02-08T00:00:00.000Z  # Optional
tags:
  - tag1
  - tag2
author: content/authors/Alex-Oladele.md
header:
  image: /assets/uploads/image.png  # Optional
---
```

### TinaCMS Content Collections

**Post Collection** (`tina/collection/post.ts`):
- Manages blog posts in `_posts/`
- Fields: title, date, updated, tags, author (reference), body (rich-text)
- Auto-generates filenames with date prefix

**Author Collection** (`tina/collection/author.ts`):
- Manages author profiles in `content/authors/`
- Fields: name, avatar
- Referenced by posts via the `author` field

### Jekyll Configuration

Key settings in `_config.yml`:
- Theme: `minimal-mistakes-jekyll` with "dark" skin
- Permalink structure: `/:categories/:title/`
- Pagination: 5 posts per page
- Timezone: America/New_York
- Markdown processor: kramdown
- Syntax highlighter: rouge

## Working with Content

### Creating New Posts

**Via TinaCMS (Recommended):**
1. Start dev server: `yarn dev`
2. Navigate to http://localhost:4000/admin
3. Create new post with visual editor
4. TinaCMS handles filename generation automatically

**Manually:**
1. Create file in `_posts/` following naming convention
2. Add required frontmatter (title, date, author)
3. Write content in Markdown

### Editing Existing Posts

Edit markdown files directly in `_posts/` or use TinaCMS admin interface at `/admin` during development.

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
- Node.js 20.10.0

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
- Author profile disabled on posts
- Wide layout for posts
- Search enabled with Lunr
- Google Analytics configured (tracking ID: G-08Y6JZGV0F)
