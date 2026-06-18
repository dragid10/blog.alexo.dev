---
title: "Test: Link Card Embeds"
description: Testing remark-link-card-plus renders link cards correctly
pubDatetime: 2026-06-18T00:00:00Z
tags: [test]
---

## Link card test

A bare URL should render as a card:

https://chocobosam.com/

https://github.com

https://astro.build

## Normal links (should NOT become cards)

Here's an [inline link to GitHub](https://github.com) that stays as text.

- And a bare URL inside a list item stays as-is: https://example.com
