import sanitizeHtml from "sanitize-html";
import MarkdownIt from "markdown-it";

const parser = new MarkdownIt({ html: true });

const ALLOWED_TAGS = [
  "h1", "h2", "h3", "h4", "h5", "h6",
  "p", "br", "hr", "blockquote", "pre", "code",
  "ul", "ol", "li", "dl", "dt", "dd",
  "a", "img", "em", "strong", "b", "i", "u", "s",
  "sub", "sup", "small",
  "table", "thead", "tbody", "tr", "th", "td",
  "div", "span",
];

const ALLOWED_ATTRIBUTES: Record<string, string[]> = {
  a: ["href", "title"],
  img: ["src", "alt", "width", "height"],
  td: ["align"],
  th: ["align"],
};

export function sanitizeRssHtml(markdown: string): string {
  return sanitizeHtml(parser.render(markdown), {
    allowedTags: ALLOWED_TAGS,
    allowedAttributes: ALLOWED_ATTRIBUTES,
  });
}

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
  const html = sanitizeRssHtml(markdown);
  return rewriteRelativeUrls(html, siteUrl);
}
