import { defineConfig } from "vitest/config";
import { resolve } from "path";

export default defineConfig({
  resolve: {
    alias: {
      "@/": resolve(__dirname, "src") + "/",
      "@/astro-paper.config": resolve(__dirname, "astro-paper.config.ts"),
    },
  },
  test: {
    include: ["src/**/*.test.{ts,js}"],
  },
});
