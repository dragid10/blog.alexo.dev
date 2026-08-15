import { describe, it, expect } from "vitest";
import { stripLocale } from "./withBase";

describe("stripLocale", () => {
  it("strips locale prefix from path", () => {
    expect(stripLocale("/en/posts/foo", "en")).toBe("/posts/foo");
  });

  it("strips locale-only path to root", () => {
    expect(stripLocale("/en", "en")).toBe("/");
  });

  it("returns path unchanged if no locale prefix", () => {
    expect(stripLocale("/posts/foo", "en")).toBe("/posts/foo");
  });

  it("returns root unchanged", () => {
    expect(stripLocale("/", "en")).toBe("/");
  });

  it("does not strip partial locale matches", () => {
    expect(stripLocale("/enterprise/page", "en")).toBe("/enterprise/page");
  });

  it("handles different locales", () => {
    expect(stripLocale("/fr/about", "fr")).toBe("/about");
  });

  it("handles deeply nested paths", () => {
    expect(stripLocale("/en/posts/2024/my-post", "en")).toBe(
      "/posts/2024/my-post"
    );
  });
});
