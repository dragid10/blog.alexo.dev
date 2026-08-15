import { describe, it, expect, vi, beforeEach } from "vitest";

vi.mock("@/config", () => ({
  default: {
    posts: { scheduledPostMargin: 15 * 60 * 1000 },
  },
}));

import { postFilter } from "./postFilter";

function makePost(overrides: {
  draft?: boolean;
  pubDatetime?: string | Date;
}) {
  return {
    data: {
      draft: overrides.draft ?? false,
      pubDatetime: overrides.pubDatetime ?? "2024-01-01T00:00:00Z",
    },
  } as any;
}

describe("postFilter", () => {
  beforeEach(() => {
    vi.stubGlobal("Date", globalThis.Date);
  });

  it("excludes drafts", () => {
    expect(postFilter(makePost({ draft: true }))).toBe(false);
  });

  it("includes published non-draft posts with past dates", () => {
    expect(
      postFilter(makePost({ pubDatetime: "2020-01-01T00:00:00Z" }))
    ).toBe(true);
  });

  it("excludes future scheduled posts in production", () => {
    vi.stubEnv("DEV", false);
    const future = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
    expect(postFilter(makePost({ pubDatetime: future }))).toBe(false);
  });

  it("includes posts within the scheduled margin", () => {
    const withinMargin = new Date(
      Date.now() + 10 * 60 * 1000
    ).toISOString();
    expect(postFilter(makePost({ pubDatetime: withinMargin }))).toBe(true);
  });
});
