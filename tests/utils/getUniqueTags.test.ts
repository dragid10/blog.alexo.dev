import { describe, it, expect, vi } from "vitest";

vi.mock("@/config", () => ({
  default: {
    posts: { scheduledPostMargin: 15 * 60 * 1000 },
  },
}));

import { getUniqueTags } from "@/utils/getUniqueTags";

function makePost(tags: string[], draft = false) {
  return {
    data: {
      draft,
      tags,
      pubDatetime: "2020-01-01T00:00:00Z",
    },
  } as any;
}

describe("getUniqueTags", () => {
  it("returns unique tags sorted alphabetically", () => {
    const posts = [
      makePost(["python", "devops"]),
      makePost(["linux", "python"]),
    ];
    const tags = getUniqueTags(posts);
    expect(tags.map(t => t.tag)).toEqual(["devops", "linux", "python"]);
  });

  it("deduplicates tags by slug", () => {
    const posts = [makePost(["Python", "python"])];
    const tags = getUniqueTags(posts);
    expect(tags.filter(t => t.tag === "python")).toHaveLength(1);
  });

  it("preserves original tagName for display", () => {
    const posts = [makePost(["Open Source"])];
    const tags = getUniqueTags(posts);
    expect(tags[0].tagName).toBe("Open Source");
  });

  it("excludes tags from draft posts", () => {
    const posts = [
      makePost(["visible"], false),
      makePost(["hidden"], true),
    ];
    const tags = getUniqueTags(posts);
    expect(tags.map(t => t.tag)).toEqual(["visible"]);
  });

  it("returns empty array when no posts", () => {
    expect(getUniqueTags([])).toEqual([]);
  });

  it("returns empty array when all posts are drafts", () => {
    const posts = [makePost(["tag1"], true)];
    expect(getUniqueTags(posts)).toEqual([]);
  });
});
