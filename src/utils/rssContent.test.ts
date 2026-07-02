import { describe, it, expect } from "vitest";
import { sanitizeRssHtml, rewriteRelativeUrls, renderRssContent } from "./rssContent";

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

  it("handles path traversal attempts in src", () => {
    const html = '<img src="/assets/../../etc/passwd" alt="test" />';
    const result = rewriteRelativeUrls(html, SITE_URL);
    expect(result).toContain('src="https://alexo.dev/assets/../../etc/passwd"');
  });
});

describe("sanitizeRssHtml", () => {
  it("strips script tags", () => {
    const result = sanitizeRssHtml('<script>alert("xss")</script>hello');
    expect(result).not.toContain("<script>");
    expect(result).toContain("hello");
  });

  it("strips iframe tags even with html passthrough enabled", () => {
    const result = sanitizeRssHtml('<iframe src="https://evil.com"></iframe>');
    expect(result).not.toContain("<iframe");
  });

  it("strips style attributes even with html passthrough enabled", () => {
    const result = sanitizeRssHtml('<div style="background:url(evil)">content</div>');
    expect(result).not.toContain("style=");
    expect(result).toContain("content");
  });

  it("strips script tags injected as raw HTML", () => {
    const result = sanitizeRssHtml('<script>document.cookie</script>');
    expect(result).not.toContain("<script");
    expect(result).not.toContain("document.cookie");
  });

  it("strips onerror handlers on img tags", () => {
    const result = sanitizeRssHtml('<img src="x" onerror="alert(1)" />');
    expect(result).toContain("<img");
    expect(result).not.toContain("onerror");
  });

  it("strips onclick handlers on links", () => {
    const result = sanitizeRssHtml('<a href="https://example.com" onclick="alert(1)">click</a>');
    expect(result).toContain('href="https://example.com"');
    expect(result).not.toContain("onclick");
  });

  it("strips form tags", () => {
    const result = sanitizeRssHtml('<form action="https://evil.com"><input type="text" /></form>');
    expect(result).not.toContain("<form");
    expect(result).not.toContain("<input");
  });

  it("allows markdown img tags with src, alt, width, height", () => {
    const md = '![photo](/assets/uploads/photo.png)';
    const result = sanitizeRssHtml(md);
    expect(result).toContain("<img");
    expect(result).toContain('src="/assets/uploads/photo.png"');
    expect(result).toContain('alt="photo"');
  });

  it("passes through raw HTML img tags (not escaped)", () => {
    const md = '<img src="/assets/uploads/photo.png" alt="test" width="300" />';
    const result = sanitizeRssHtml(md);
    expect(result).toContain("<img");
    expect(result).toContain('src="/assets/uploads/photo.png"');
    expect(result).toContain('width="300"');
    expect(result).not.toContain("&lt;img");
  });

  it("allows basic formatting tags", () => {
    const md = "**bold** and *italic* and [link](https://example.com)";
    const result = sanitizeRssHtml(md);
    expect(result).toContain("<strong>bold</strong>");
    expect(result).toContain("<em>italic</em>");
    expect(result).toContain("<a");
  });

});

describe("renderRssContent", () => {
  it("sanitizes and rewrites in one pass", () => {
    const md = '![photo](/assets/uploads/photo.png)\n\n<script>alert("xss")</script>';
    const result = renderRssContent(md, SITE_URL);
    expect(result).toContain('src="https://alexo.dev/assets/uploads/photo.png"');
    expect(result).not.toContain("<script>");
  });
});
