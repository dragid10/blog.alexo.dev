import type { Collection } from "tinacms";

const Speaking: Collection = {
  name: "speaking",
  label: "Speaking",
  path: "src/data",
  format: "yaml",
  match: {
    include: "speaking",
  },
  fields: [
    {
      type: "object",
      name: "engagements",
      label: "Engagements",
      list: true,
      fields: [
        {
          type: "number",
          name: "year",
          label: "Year",
          required: true,
        },
        {
          type: "string",
          name: "event",
          label: "Event",
          required: true,
        },
        {
          type: "string",
          name: "type",
          label: "Type",
          options: [
            "Conference talk",
            "Guest lecture",
            "Podcast",
            "Panel",
            "Workshop",
          ],
        },
        {
          type: "string",
          name: "talk",
          label: "Talk Title",
          required: true,
        },
        {
          type: "string",
          name: "recap",
          label: "Recap URL",
        },
        {
          type: "string",
          name: "slides",
          label: "Slides URL",
        },
        {
          type: "string",
          name: "video",
          label: "Video URL",
        },
        {
          type: "string",
          name: "page",
          label: "Detail Page",
          description: "Root-relative path to a per-talk page",
        },
      ],
    },
  ],
};

export default Speaking;
