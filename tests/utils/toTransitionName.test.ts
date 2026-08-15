import { describe, it, expect } from "vitest";
import { toTransitionName } from "@/utils/toTransitionName";

describe("toTransitionName", () => {
  it("converts simple strings to valid CSS idents", () => {
    expect(toTransitionName("Hello World")).toBe("hello-world");
  });

  it("converts dots to hyphens", () => {
    expect(toTransitionName("my.post.title")).toBe("my-post-title");
  });

  it("prefixes digit-starting results with p-", () => {
    expect(toTransitionName("2024 recap")).toBe("p-2024-recap");
  });

  it("hex-encodes non-ASCII characters", () => {
    const result = toTransitionName("日本語");
    expect(result).toMatch(/^u[0-9a-f]{6}/);
    expect(result).not.toMatch(/[^\x00-\x7F]/);
  });

  it("collapses consecutive hyphens", () => {
    expect(toTransitionName("a---b")).toBe("a-b");
  });

  it("trims leading and trailing hyphens", () => {
    const result = toTransitionName("--test--");
    expect(result).not.toMatch(/^-/);
    expect(result).not.toMatch(/-$/);
  });

  it("returns 'post' for empty string", () => {
    expect(toTransitionName("")).toBe("post");
  });

  it("handles file-path-like strings", () => {
    const result = toTransitionName("posts/my-cool-post");
    expect(result).toMatch(/^[a-zA-Z][a-zA-Z0-9_-]*$/);
  });

  it("produces valid CSS custom-ident (no colons, slashes)", () => {
    const result = toTransitionName("section:main/page");
    expect(result).not.toMatch(/[:/]/);
    expect(result).toMatch(/^[a-zA-Z_p-][a-zA-Z0-9_-]*$/);
  });
});
