import type { Collection } from "tinacms";

const Post: Collection = {
    name: "post",
    label: "Posts",
    path: "_posts",
    format: "md",
    defaultItem: () => ({
        title: "New Post",
        layout: "_layouts/single.html",
        date: new Date(),
        updated: new Date(),
        tags: [],
    }),
    ui: {
        dateFormat: "MMM DD YYYY",
        filename: {
            readonly: false,
            slugify: (values) => {
                const date = new Date();
                const day = date.getDate();
                const month = date.getMonth() + 1;
                const year = date.getFullYear();

                let currentDate = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;

                return `${currentDate}-${values?.title?.toLowerCase().replace(/ /g, '_')}`
            },
        },
    },
    // Fields to include in frontmatter for each post
    fields: [
        // Title
        {
            type: "string",
            name: "title",
            label: "Title",
            isTitle: true,
            required: true,
        },

        // Date Added
        {
            label: "Date",
            name: "date",
            type: "datetime",
            ui: {
                dateFormat: "MMM DD YYYY",
                parse: (value) => value && value.format("MMM DD YYYY"),
            },
            required: true,
        },

        // Date Updated
        {
            label: "Updated",
            name: "updated",
            type: "datetime",
            ui: {
                dateFormat: "MMM DD YYYY",
                parse: (value) => value && value.format("MMM DD YYYY"),
            },
        },

        // Tags
        {
            label: 'Tags',
            name: 'tags',
            type: 'string',
            list: true,
        },

        // Author
        {
            type: "reference",
            label: "Author",
            name: "author",
            collections: ["author"],
            searchable: false, // Disable indexing of the author field
        },

        // Body
        {
            type: "rich-text",
            name: "body",
            label: "Body",
            isBody: true,
        },
    ],
};

export default Post;
