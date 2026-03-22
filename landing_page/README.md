# Yapper Landing Page

Static marketing site for Yapper built with Astro, Bun, TypeScript, and plain CSS.

## Stack

- Bun for package management and scripts
- Astro for static routing and component composition
- TypeScript for typed copy/config
- Plain CSS with design tokens derived from `stitch_reference/DESIGN.md`
- Optional Docker image with Caddy for serving the built site

## Project layout

```text
src/
  components/   reusable layout, section, and UI components
  data/         site copy, pricing, and legal page data
  layouts/      page wrapper and metadata
  pages/        route files
  styles/       tokens and global styling
```

## Development

```bash
bun install
bun run dev
```

## Build

```bash
bun run build
```

## Docker

```bash
docker build -t yapper-landing .
docker run --rm -p 8080:8080 yapper-landing
```

## Notes

- Replace placeholder legal copy before launch.
- Update `src/data/site.ts` with the real App Store URL, canonical site URL, and contact emails.
- `stitch_reference/` keeps the original design inputs and generated example for comparison.
