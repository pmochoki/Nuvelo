# Nuvelo — autonomous tasks (Supabase + Vercel) — 2026-04-09

## Site-wide fixes session — 2026-04-09 (tasks 1–5)

| Task | Status | Notes |
|------|--------|--------|
| **1 — Mobile layout** | **Done** | `#app.main--jiji` / `.main--jiji`: `width/max-width: 100%`, horizontal padding `max(16px, safe-area)`, `min-width: 0`; `body` full-width navy background; `.feed-layout--browse` / `.browse-layout--jiji` full width; profile pill nav: `display: flex`, `overflow-x: auto`, `-webkit-overflow-scrolling: touch`, `scrollbar-width: none`, `padding: 8px 16px`, `gap: 8px`; profile content cards `margin: 0 0 16px`, `border-radius: 16px`. |
| **2 — Browse / API** | **Done** | `web/src/lib/listingsApi.js`: `[Nuvelo]`-prefixed `console.error` / `console.warn` for failures, empty results, and a one-shot unfiltered `/listings` probe when filters return 0 rows; logs full request URL. Empty copy: **“No listings yet — be the first to post!”** + Post CTA. Error: **“Could not load listings. Try refreshing.”** Skeleton already 4 cards in `buildBrowseSkeletonHtml`. **API:** browser calls **`VITE_API_URL` or same-origin `/api/listings`** (Vercel Functions in repo root `api/`). **`vercel.json`** rewrites non-`/api/*` to SPA; **`/api/*` is not proxied to Render** — listings are handled by **`api/listings/index.js`** (Supabase or file store when env set). |
| **3 — Messaging** | **Done (code + DB)** | Supabase MCP **`apply_migration`**: applied **`message_threads` / `messages`** schema matching **`web/src/lib/messaging.js`** (participant_low/high — not buyer/seller-only). **`web/src/lib/messaging.js`**: generic errors only (no raw Supabase strings). **`main.js`**: user-facing **“Could not load messages. Try again.”** |
| **4 — Profile / settings** | **Done** | **Avatars:** `mergeProfileAvatarFromDb` clears local data-URL when `profiles.avatar_url` is HTTPS; settings form prefers remote photo when Supabase is on; bucket migration applied via MCP + **`supabase/migrations/20260411120100_storage_avatars_bucket.sql`** (jpeg/png/webp, 5MB). **My adverts:** sample/mock listings only in **`import.meta.env.DEV`** with no Supabase; production never shows SAMPLE. **Selects:** reinforced white `#fff` / `#111`, chevron, `z-index`, `margin-bottom`. |
| **5 — SEO / notifications** | **Done** | **`middleware.js`**: TODO comment block for **`PRERENDER_TOKEN`**. **Notifications:** table applied via MCP + migration **`20260411120000_notifications.sql`**; **`web/src/lib/notificationsApi.js`** + **`initNotificationsPageUi`** loads rows or empty / error copy. |

**Database (project `ahiujuljjbozmfwoqtli`) — applied via MCP this session**

- **`public.message_threads`**, **`public.messages`** — yes (migration aligned with app).
- **`public.notifications`** — yes.
- **Storage `avatars` bucket** — yes (policies in migration file).

**Could not verify remotely**

- End-to-end **nuvelo.one** browse/messages in a browser from this environment (no automated run). If browse is still empty, confirm **`api/listings`** returns rows (Supabase **`SUPABASE_SERVICE_ROLE_URL`** + listings table on Vercel, or file store fallback).

---

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

---

## Mobile + messaging + storage — 2026-04-10

### TASK 1 — `message_threads` / `messages` (Supabase project `ahiujuljjbozmfwoqtli`)

**Completed in repo**

- Added versioned migration **`supabase/migrations/20260410140000_messaging_threads_and_messages.sql`** — matches **`web/src/lib/messaging.js`** (participant_low/high, `listing_id` **text**, `body` on messages — **not** the buyer/seller-only draft from the prompt).
- **`supabase/messaging.sql`** remains the same logical definition (manual run).

**Manual (you)**

1. Open **Supabase Dashboard** → **SQL Editor** for project **`ahiujuljjbozmfwoqtli`**.
2. Paste and run **`supabase/migrations/20260410140000_messaging_threads_and_messages.sql`** (or `messaging.sql`).
3. Optional: **Database → Replication** → enable **`messages`** for realtime chat UI.

**Listings table**

- The app does **not** FK `message_threads.listing_id` to Postgres `listings` — listing ids come from the **Vercel `/api` listings** model (see **`api/_listingsDb.js`** / **`nuvelo_listings`** and/or **`supabase/schema.sql`** `public.listings`). Either can exist independently; threads only store **`listing_id` as text**.

**Verify**

- Reload **https://nuvelo.one/profile/messages** — the schema-cache error should disappear after migration. Until then the client still shows the friendly banner (no raw SQL in UI).

---

### TASK 2 — Full-width mobile layout

**Completed**

- **`web/styles.css`**: `.main--jiji` on small viewports uses **16px** horizontal padding, **width/max-width 100%**; **`.profile-shell`** drops side padding on mobile so content aligns with the main shell; **`.profile-layout--jiji`** no longer adds extra horizontal inset; **`.profile-content`** gets **16px-radius** cards and full width on mobile; **`.jiji-header__inner`** and **footer grid** use **16px** side padding on small screens; profile tab row gets **gap: 8px** and **width 100%**.

---

### TASK 3 — Settings form (dropdowns / separation)

**Completed**

- Form fields under **`.profile-layout--settings-jiji`** use **12px** bottom spacing (with exceptions for photo block and action row).
- **Select** fields: explicit **white** background / **#111** text, **`appearance: none`** (custom chevron rules already in stylesheet for `.form-select` where applicable).

---

### TASK 4 — Avatars in Supabase Storage

**Completed in repo**

- **`web/src/lib/avatarUpload.js`** — uploads to bucket **`avatars`**, path **`{user_id}/avatar.{ext}`**, max **5MB**, then **`profiles` upsert** for **`avatar_url`**.
- **`web/src/main.js`** — **`persistAvatarFromFile`** uses Storage when Supabase is configured; otherwise keeps local **data URL** fallback; **`mergeProfileAvatarFromDb()`** loads **`profiles.avatar_url`** on session init; settings hint text updated to **“JPG, PNG or WebP, max 5MB.”**
- **`supabase/storage_avatars.sql`** — bucket + RLS policies (public read, users write only under their **`auth.uid()`** folder).

**Manual (you)**

1. Run **`supabase/storage_avatars.sql`** in SQL Editor **or** create bucket **`avatars`** in Dashboard (public, ~5MB, image MIME types) and add equivalent policies.
2. If upload fails with **bucket missing**, create the bucket first, then re-run policies.

---

### TASK 5 — Remove sample UI for signed-in production

**Completed**

- **My adverts**: Sample listings + **Sample** pill + hint only when **`!isSupabaseConfigured`** and the user has no ads. With Supabase + zero ads → empty state **“You haven't posted any ads yet…”** (no sample badge).
- **Notifications**: **“No notifications yet.”** — removed mock list and disclaimer.

---

### Anything blocked / errors

- **Supabase SQL** was **not** executed from this environment — apply migrations in the Dashboard.
- **`storage.foldername(name)`** in **`storage_avatars.sql`** is the usual Supabase helper; if your project errors, replace checks with e.g. **`split_part(name, '/', 1) = auth.uid()::text`**.

---

## Admin dashboard rebuild — 2026-04-09

### What was replaced

- Replaced **`web/admin.html`** from a minimal moderation shell with a full internal admin dashboard UI (single-file app with inline CSS + JS).
- Kept password gate behavior but upgraded to **SHA-256 hash comparison** for `nuvelo-admin` and session stored in `sessionStorage`.
- Added Supabase env bootstrap via `window.__env` with fallback URL `https://ahiujuljjbozmfwoqtli.supabase.co`.

### Pages currently connected to live Supabase/API data

- **Dashboard**: live listings (via `/api/listings` fan-out by status), live profiles from `public.profiles`, live chart/table generation.
- **All listings** + **Pending review**: live rows from listings API; approve/reject/ban uses `/api/admin/listings/:id/status` first, with direct `public.nuvelo_listings` fallback when available.
- **All users**: live rows from `public.profiles`.
- **Site settings**: reads/writes `public.site_config` when table/policies permit.
- **API health / system**: live checks for Supabase Auth and `/api/health` + optional `/api/meta`.

### Pages currently placeholder/empty (schema pending)

- Flagged users, verification queue
- Reported listings (dedicated table not wired yet)
- Banned content list, appeals
- Revenue/boost/payout data (payments table not present)
- Categories and locations management pages
- Admin accounts management page

### Tables needed for full functionality

- **Required for connected features**:
  - `public.profiles`
  - `public.nuvelo_listings` (or compatible backend admin API)
  - `public.site_config` (new migration added)
- **Recommended for complete admin product**:
  - `public.reports` (listing/user reports queue)
  - `public.user_flags`
  - `public.verification_requests`
  - `public.appeals`
  - `public.payments` / `public.boost_purchases`
  - `public.payouts`
  - `public.admin_accounts` (or roles mapped in `profiles`)
