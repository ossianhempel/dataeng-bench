import { defineConfig } from "astro/config";

// GitHub Pages serves the site from /<repo>/. Set SITE_BASE=/ for a root domain.
export default defineConfig({
  site: process.env.SITE_URL ?? "https://ossianhempel.github.io",
  base: process.env.SITE_BASE ?? "/dataeng-bench",
  trailingSlash: "always",
});
