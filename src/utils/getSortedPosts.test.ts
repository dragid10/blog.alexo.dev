import { describe, it, expect, vi } from "vitest";

vi.mock("@/config", () => ({
  default: {
    posts: { scheduledPostMargin: 15 * 60 * 1000 },
  },
}));

import { getSortedPosts } from "./getSortedPosts";

function makePost(
  id: string,
  opts: {
    pubDatetime: string;
    modDatetime?: string;
    draft?: boolean;
  }
) {
  return {
    id,
    data: {
      draft: opts.draft ?? false,
      pubDatetime: opts.pubDatetime,
      modDatetime: opts.modDatetime ?? null,
    },
  } as any;
}

describe("getSortedPosts", () => {
  it("sorts posts by pubDatetime descending", () => {
    const posts = [
      makePost("old", { pubDatetime: "2023-01-01T00:00:00Z" }),
      makePost("new", { pubDatetime: "2024-06-01T00:00:00Z" }),
      makePost("mid", { pubDatetime: "2024-01-01T00:00:00Z" }),
    ];
    const sorted = getSortedPosts(posts);
    expect(sorted.map(p => p.id)).toEqual(["new", "mid", "old"]);
  });

  it("uses modDatetime when available for sorting", () => {
    const posts = [
      makePost("updated-old", {
        pubDatetime: "2023-01-01T00:00:00Z",
        modDatetime: "2025-01-01T00:00:00Z",
      }),
      makePost("newer-pub", { pubDatetime: "2024-06-01T00:00:00Z" }),
    ];
    const sorted = getSortedPosts(posts);
    expect(sorted[0].id).toBe("updated-old");
  });

  it("excludes drafts", () => {
    const posts = [
      makePost("published", { pubDatetime: "2024-01-01T00:00:00Z" }),
      makePost("draft", {
        pubDatetime: "2024-06-01T00:00:00Z",
        draft: true,
      }),
    ];
    const sorted = getSortedPosts(posts);
    expect(sorted).toHaveLength(1);
    expect(sorted[0].id).toBe("published");
  });

  it("returns empty array for no eligible posts", () => {
    const posts = [
      makePost("draft", {
        pubDatetime: "2024-01-01T00:00:00Z",
        draft: true,
      }),
    ];
    expect(getSortedPosts(posts)).toEqual([]);
  });

  it("handles single post", () => {
    const posts = [
      makePost("only", { pubDatetime: "2024-01-01T00:00:00Z" }),
    ];
    expect(getSortedPosts(posts)).toHaveLength(1);
  });
});
