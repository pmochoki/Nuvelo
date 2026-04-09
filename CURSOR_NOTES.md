# Nuvelo — autonomous tasks (Supabase + Vercel) — 2026-04-09

## TASK 1 — Supabase env vars in Vercel

**Completed**

- Retrieved **Project URL** and **legacy anon JWT** from the linked Supabase project via MCP (`get_project_url`, `get_publishable_keys`).
- Applied/overrode on Vercel project `nuvelo` (team `pmochoki-2021s-projects`) using `vercel env add`:
  - **`VITE_SUPABASE_URL`** → `https://ahiujuljjbozmfwoqtli.supabase.co` for **Production** and **Development**.
  - **`VITE_SUPABASE_ANON_KEY`** → current legacy anon key for **Production** and **Development** (sensitive).
- **Redeploy:** ran `vercel deploy --prod --scope pmochoki-2021s-projects --yes` — deployment **READY**, production alias **https://nuvelo.one** (`dpl_Fq9m1Ut4fszan2KKnVHDj6AuM7EX`).

**Partial / manual**

- **Preview** environment: CLI requires a **Git branch** that exists on the **Vercel-connected** repo, or a dedicated “all preview branches” flow that this CLI version did not complete non-interactively (`git_branch_required` / `branch_not_found` for `main` / `*`). **Preview may still use older values** until you set them in the Vercel UI: Settings → Environment Variables → Preview, or connect the correct Git default branch and re-run CLI.

**Verify sign-in (manual)**

- Open **https://nuvelo.one** → Sign in: confirm no config error and **Continue** works. (Automated browser verification was not run here.)

**Save securely (you)**

- Supabase **legacy anon JWT** (used for `VITE_SUPABASE_ANON_KEY`) — already in Vercel; also available in Supabase Dashboard → API. **Do not commit** to git.

---

## TASK 2 — Prerender.io (middleware)

**Completed**

- Added **`/Users/mokoro/Nuvelo/middleware.js`** (Vercel Routing Middleware, Edge): detects crawler User-Agents, and if **`PRERENDER_TOKEN`** is set, proxies to Prerender.io (`https://service.prerender.io/<encoded-url>` with header **`X-Prerender-Token`**). Non-bots or missing token → **`return fetch(request)`** (normal SPA).
- **`PRERENDER_TOKEN`** was **not** set (requires your Prerender.io signup). Add in Vercel: **Settings → Environment Variables** → `PRERENDER_TOKEN` (all environments), **no `VITE_` prefix**.

**Failed / pending**

- **Prerender account + token** — cannot be created without your Preregister.io login; add token after signup.

**Verify (`curl -A Googlebot`)**

- **Before** token: response is still the built **`index.html`** shell (includes static `<title>` / OG tags from the HTML file — not empty).
- **After** token: repeat `curl -A "Googlebot" https://nuvelo.one/` — expect Prerender-served HTML with route-specific content once crawlers execute JS or Prerender cache is warm.

---

## TASK 3 — Google Search Console

**Not completed (blocked)**

- **HTML tag verification** needs the real **`content="..."`** value from Search Console. **`web/index.html`** still has **`content="XXXXX"`**.
- **You:** Search Console → property `https://nuvelo.one` → HTML tag → paste value into `index.html`, redeploy, click Verify.
- **Sitemaps to submit** (after verification):  
  `https://nuvelo.one/sitemap.xml`  
  `https://nuvelo.one/listings-sitemap.xml`

---

## TASK 4 — Social URLs from Supabase

**Completed (finding)**

- Queried DB: **`public` schema has no user tables** (empty). No `site_config` / `settings` table found.
- **Footer:** left **TODO** placeholder links in **`web/index.html`** as before; **you** must confirm real **X** and **YouTube** URLs.

---

## TASK 5 — Keep-alive for listings backend

**Completed**

1. **Vercel Cron** — **`vercel.json`** and **`web/vercel.json`**: `crons` entry **`GET /api/health`** every **`*/5 * * * *`**. That route (**`api/health.js`**) proxies to **`LISTINGS_BACKEND_URL` / `NUVELO_API_URL`** (default **`https://nuvelo-backend.onrender.com`**) **`/health`**.
2. **Supabase Edge Function `keep-alive`** — deployed **`ACTIVE`** (JWT **disabled**). Source mirrored at **`supabase/functions/keep-alive/index.ts`**.  
   - Invoke URL: **`https://ahiujuljjbozmfwoqtli.supabase.co/functions/v1/keep-alive`**  
   - Manual test returned **200** JSON; upstream **`/health`** and **`/`** on the default Render host currently return **404** (still logs status; useful for wake/network).
3. **pg_cron / 5‑min DB schedule** — **`pg_cron` / `pg_net` are not installed** on this database (`pg_extension` query returned no rows for them). **Not configured** via SQL here. Options: enable extensions in Supabase (if plan allows) and schedule `net.http_get`, or use **Supabase scheduled functions** in Dashboard, or rely on **Vercel Cron** above.

**Save securely**

- Optional: set **`LISTINGS_BACKEND_URL`** or **`NUVELO_API_URL`** on Vercel for `/api/health` if not using the Render default.

---

## Additional findings

- **Supabase `public` schema** has **no application tables** yet (listings may be intended elsewhere or not migrated).
- **Render default backend** responds **404** on `/` and `/health`; keep-alive still exercises network path.
- **Vercel Cron** may require a **paid** Vercel plan — if cron is ignored, use an external ping or Supabase scheduling only.

---

## Commits (this session)

1. **TASK 1** — Environment sync documented; empty commit optional (see git log).
2. **TASK 2 + 5** — `middleware.js`, `vercel.json` / `web/vercel.json` (crons), `supabase/functions/keep-alive/index.ts`.
3. **Documentation** — this `CURSOR_NOTES.md`.
