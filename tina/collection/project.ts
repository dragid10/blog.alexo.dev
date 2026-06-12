import type { Collection } from "tinacms";

const Project: Collection = {
  name: "project",
  label: "Projects",
  path: "src/content/projects",
  format: "md",
  defaultItem: () => ({
    title: "New Project",
    description: "",
    status: "active",
    tags: [],
    featured: false,
  }),
  ui: {
    filename: {
      readonly: false,
      slugify: values =>
        values?.title
          ?.toLowerCase()
          .replace(/[^a-z0-9]+/g, "-")
          .replace(/^-+|-+$/g, "") || "untitled",
    },
  },
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
      description: "One-liner for the project card",
      required: true,
      ui: { component: "textarea" },
    },
    {
      type: "string",
      name: "repo",
      label: "Repository URL",
    },
    {
      type: "string",
      name: "demo",
      label: "Demo / Live URL",
    },
    {
      type: "string",
      name: "status",
      label: "Status",
      options: ["active", "maintained", "archived"],
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
      description: "Show at the top of the projects page",
    },
    {
      label: "Order",
      name: "order",
      type: "number",
      description: "Sort order (lower = first)",
    },
    {
      type: "rich-text",
      name: "body",
      label: "Body",
      isBody: true,
    },
  ],
};

export default Project;
