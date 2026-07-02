import sanitizeHtml from "sanitize-html";
import MarkdownIt from "markdown-it";

const parser = new MarkdownIt();

export function rewriteRelativeUrls(html: string, siteUrl: string): string {
  const origin = siteUrl.replace(/\/$/, "");
  return html
    .replace(/src="\/([^"]+)"/g, (_, path) => {
      if (path.startsWith("assets/")) return `src="${origin}/${path}"`;
      return `src="/${path}"`;
    })
    .replace(/href="\/([^"]+)"/g, (_, path) => {
      if (path.startsWith("posts/") || path.startsWith("assets/"))
        return `href="${origin}/${path}"`;
      return `href="/${path}"`;
    });
}

export function renderRssContent(markdown: string, siteUrl: string): string {
  const html = sanitizeHtml(parser.render(markdown), {
    allowedTags: sanitizeHtml.defaults.allowedTags.concat(["img"]),
  });
  return rewriteRelativeUrls(html, siteUrl);
}
