# Results site

A static [Astro](https://astro.build) site that reads `../tasks` and `../runs`
at build time. No database and no client framework: every page is plain HTML,
with a few lines of inline JS for tooltips and task filters.

```bash
cd site
npm install
npm run dev                      # http://localhost:4321/dataeng-bench/ (includes draft runs)
npm run build                    # public build in dist/ (published runs only)
INCLUDE_DRAFTS=1 npm run build   # preview build with drafts
```

Pages:

- `/` the latest published run: ranked chart, breakdown and a task-by-variant heatmap.
- `/runs/` every run, and `/runs/<id>/` with its variants and settings.
- `/tasks/` filterable list, and `/tasks/<slug>/` with the prompt, grading, sources and per-run scores.

Run files follow [docs/results-format.md](../docs/results-format.md).
Deployed to GitHub Pages by `.github/workflows/site.yml` on every push to `main`.
Set `SITE_BASE=/` and `SITE_URL` if it moves to its own domain.
