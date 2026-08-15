import { describe, it, expect } from "vitest";
import { slugifyStr, slugifyAll } from "@/utils/slugify";

describe("slugifyStr", () => {
  it("lowercases and kebab-cases latin strings", () => {
    expect(slugifyStr("E2E Testing")).toBe("e2e-testing");
  });

  it("handles simple words", () => {
    expect(slugifyStr("Hello World")).toBe("hello-world");
  });

  it("preserves already-slugified strings", () => {
    expect(slugifyStr("my-tag")).toBe("my-tag");
  });

  it("handles single word", () => {
    expect(slugifyStr("python")).toBe("python");
  });

  it("strips special characters", () => {
    expect(slugifyStr("What's Up?")).toBe("what's-up");
  });

  it("uses kebabcase for non-latin characters", () => {
    const result = slugifyStr("日本語テスト");
    expect(result).toBe("日本語テスト");
  });

  it("handles mixed latin and non-latin", () => {
    const result = slugifyStr("Hello 世界");
    expect(result).toContain("hello");
    expect(result).toContain("世界");
  });
});

describe("slugifyAll", () => {
  it("slugifies an array of strings", () => {
    expect(slugifyAll(["Hello World", "python", "E2E Testing"])).toEqual([
      "hello-world",
      "python",
      "e2e-testing",
    ]);
  });

  it("returns empty array for empty input", () => {
    expect(slugifyAll([])).toEqual([]);
  });
});
