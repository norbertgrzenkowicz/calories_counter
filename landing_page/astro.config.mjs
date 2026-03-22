import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://yapper.app",
  output: "static",
  server: {
    host: true
  }
});
