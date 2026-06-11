import type { Collection } from "tinacms";

const Post: Collection = {
  name: "post",
  label: "Posts",
  path: "src/content/posts",
  format: "md",
  defaultItem: () => ({
    title: "New Post",
    description: "",
    pubDatetime: new Date().toISOString(),
    tags: [],
  }),
  ui: {
    filename: {
      readonly: false,
      slugify: (values) =>
        values?.title
          ?.toLowerCase()
          .replace(/[^a-z0-9]+/g, "-")
          .replace(/^-+|-+$/g, "") || "untitled",
    },
  },
  // Fields match the AstroPaper content schema (src/content.config.ts)
  fields: [
    {
      type: "string",
      name: "title",
      label: "Title",
      isTitle: true,
      required: true,
    },
    {
      type: "string",
      name: "description",
      label: "Description",
      description: "Short summary used for SEO and post cards",
      required: true,
      ui: { component: "textarea" },
    },
    {
      label: "Published",
      name: "pubDatetime",
      type: "datetime",
      required: true,
    },
    {
      label: "Updated",
      name: "modDatetime",
      type: "datetime",
    },
    {
      label: "Tags",
      name: "tags",
      type: "string",
      list: true,
    },
    {
      label: "Featured",
      name: "featured",
      type: "boolean",
      description: "Pin to the Featured section on the homepage",
    },
    {
      label: "Draft",
      name: "draft",
      type: "boolean",
      description: "Drafts are excluded from the published site",
    },
    {
      label: "OG Image",
      name: "ogImage",
      type: "image",
      description: "Social preview image (optional — one is auto-generated)",
    },
    {
      type: "rich-text",
      name: "body",
      label: "Body",
      isBody: true,
    },
  ],
};

export default Post;
