import { describe, it, expect } from "vitest";
import { rewriteRelativeUrls, renderRssContent } from "./rssContent";

const SITE_URL = "https://alexo.dev";

describe("rewriteRelativeUrls", () => {
  it("rewrites asset image src to absolute URL", () => {
    const html = '<img src="/assets/uploads/my-post/photo.png" alt="test" />';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('src="https://alexo.dev/assets/uploads/my-post/photo.png"');
  });

  it("rewrites post href to absolute URL", () => {
    const html = '<a href="/posts/another-post/">link</a>';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('href="https://alexo.dev/posts/another-post/"');
  });

  it("rewrites asset href to absolute URL", () => {
    const html = '<a href="/assets/files/doc.pdf">download</a>';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('href="https://alexo.dev/assets/files/doc.pdf"');
  });

  it("does NOT rewrite non-asset, non-post relative src", () => {
    const html = '<img src="/admin/secret.png" alt="test" />';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('src="/admin/secret.png"');
    expect(result).not.toContain("https://alexo.dev/admin");
  });

  it("does NOT rewrite non-asset, non-post relative href", () => {
    const html = '<a href="/api/secret">bad link</a>';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('href="/api/secret"');
    expect(result).not.toContain("https://alexo.dev/api");
  });

  it("does NOT rewrite absolute URLs", () => {
    const html = '<a href="https://example.com/page">external</a>';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('href="https://example.com/page"');
  });

  it("handles siteUrl with trailing slash", () => {
    const html = '<img src="/assets/uploads/photo.png" alt="test" />';
    const result = rewriteRelativeUrls(html, "https://alexo.dev/");
    expect(result).toContain('src="https://alexo.dev/assets/uploads/photo.png"');
    expect(result).not.toContain("alexo.dev//");
  });
});

describe("renderRssContent", () => {
  it("renders markdown images with absolute URLs", () => {
    const md = '![photo](/assets/uploads/photo.png)';
    const result = renderRssContent(md, SITE_URL);
    expect(result).toContain('src="https://alexo.dev/assets/uploads/photo.png"');
  });

  it("renders markdown links with absolute URLs", () => {
    const md = '[other post](/posts/another-post/)';
    const result = renderRssContent(md, SITE_URL);
    expect(result).toContain('href="https://alexo.dev/posts/another-post/"');
  });
});
