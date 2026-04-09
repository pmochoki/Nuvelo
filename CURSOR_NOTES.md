# Nuvelo production-fix pass (Cursor)

## Completed

- **BUG-01** — Replaced auth config error copy with a single generic user message; removed dev-only env var instructions from `#auth-missing-config`. OAuth and legacy-deployment failures now use generic messaging; details stay in `console.warn` / `console.error` only.
- **BUG-02** — Removed cold-start / backend proxy hint from the modal. Continue button shows an inline spinner while requests run; 30s timeout shows “This is taking longer than expected. Please try again.” (Supabase and legacy login paths).
- **BUG-03** — No `react-helmet-async` (app is vanilla JS + Vite). Extended `web/src/seo.js`: `og:site_name`, listing `og:image` from first photo (absolute URL), `og:type` `article` on listing pages, description truncation 160 chars, browse/about titles per spec. `HelmetProvider` equivalent = `applyRouteMeta` / `applyDocumentMeta` on navigation.
- **BUG-04** — Footer: X and YouTube are real links with `rel="noopener"`; HTML comments request confirmation of handles/URLs. Support mail in footer → `support@nuvelo.one`.
- **BUG-05** — Browse: skeleton grid while fetching (cache miss), `console.error` with `[Nuvelo] Browse listings API error:`, user messages for error / empty broad fetch / empty filtered results, `/post` CTA when there are no listings on a broad browse.
- **BUG-06** — Static pages: legal blocks tagged `<!-- TODO: LEGAL REVIEW -->` + visible placeholder note; FAQ condensed to five required topics; About and Contact updated; emails moved to `@nuvelo.one` where shown.
- **BUG-07** — Auth: sign-in vs register modes; sign-in shows email/phone only; register shows name + role; removed separate “email pathway” buttons; SMS helper in `#auth-phone-focus-hint` (shown on phone field focus).
- **BUG-08** — `web/public/robots.txt` updated (Disallow `/profile/`, `/api/`, dual sitemaps). `api/sitemap-listings.js` + rewrite ` /listings-sitemap.xml` → dynamic listing URLs in root and `web/vercel.json`.
- **BUG-09** — City data is static (`hungarianLocations.js`); added runtime fallback list if the import were empty; location button shows “Loading locations…” + `aria-busy` while the modal panel opens.

## Could not complete (or only partially)

- **Server-rendered per-route HTML** — Still one `index.html` shell for all paths; meta updates run after JS. True crawler-first titles/descriptions need SSR, prerender, or edge HTML rewriting (not implemented).
- **Footer social URLs** — Placeholders only until you confirm real YouTube channel and X handle (TODOs in `web/index.html`).
- **Legal copy** — Remains template-level text pending lawyer review (marked in page HTML).
- **Google Search Console** — `index.html` still contains placeholder `google-site-verification` content (`XXXXX`); replace with a real token or remove.

## Other issues noticed

- Messaging and thread UI still depend on Supabase when enabled; generic banners are shown when it is not.
- `web/vercel.json` rewrites assume API routes exist in the same deployment as the static site; standalone `web`-only deploys may not resolve `/api/*` without the monorepo root project.
