import { defineAstroPaperConfig } from "./src/types/config";

export default defineAstroPaperConfig({
  site: {
    url: "https://alexo.dev/",
    title: "Alex Oladele",
    description: "Tech nerd on the internet!",
    author: "Alex Oladele",
    profile: "https://alexo.dev",
    ogImage: "default-og.jpg",
    lang: "en",
    timezone: "America/New_York",
    dir: "ltr",
  },
  posts: {
    perPage: 8,
    perIndex: 5,
    scheduledPostMargin: 15 * 60 * 1000,
  },
  features: {
    lightAndDarkMode: true,
    dynamicOgImage: true,
    showArchives: true,
    showBackButton: true,
    editPost: {
      enabled: true,
      url: "https://github.com/dragid10/blog.alexo.dev/edit/main/",
    },
    search: "pagefind",
  },
  socials: [
    { name: "github", url: "https://github.com/dragid10" },
    { name: "linkedin", url: "https://www.linkedin.com/in/alexoladele" },
    { name: "bluesky", url: "https://bsky.app/profile/wizkidalex.bsky.social" },
    { name: "mastodon", url: "https://triangletoot.party/@Wizkid_alex" },
    { name: "threads", url: "https://www.threads.net/@wizkid_alex" },
    { name: "instagram", url: "https://instagram.com/wizkid_alex" },
    { name: "storygraph", url: "https://app.thestorygraph.com/profile/wizkid_alex" },
    { name: "letterboxd", url: "https://letterboxd.com/wizkid_alex/" },
    { name: "mail", url: "mailto:oladelaa@gmail.com" },
    { name: "rss", url: "/rss.xml", linkTitle: "RSS Feed" },
  ],
  shareLinks: [
    { name: "bluesky", url: "https://bsky.app/intent/compose?text=" },
    { name: "mastodon", url: "https://triangletoot.party/share?text=" },
    { name: "mail", url: "mailto:?subject=See%20this%20post&body=" },
  ],
});
