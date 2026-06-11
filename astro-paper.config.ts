import { defineAstroPaperConfig } from "./src/types/config";

export default defineAstroPaperConfig({
  site: {
    url: "https://blog.alexo.dev/",
    title: "Alex's blog",
    description: "Alex Oladele's random thoughts",
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
    { name: "mail", url: "mailto:dragid10@gmail.com" },
  ],
  shareLinks: [
    { name: "mail", url: "mailto:?subject=See%20this%20post&body=" },
  ],
});
