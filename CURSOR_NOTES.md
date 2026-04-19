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

- **My adverts**: No mock ads in production; **0 ads** → empty state **“You haven't posted any ads yet…”** + **Post your first ad** → `/post`.
- **Notifications**: Supabase-backed list; empty copy **“No notifications yet….”** — no mock rows or disclaimer.

---

## Production sample data removal — 2026-04-15

**Goal:** No hardcoded fake listings, metrics, or promotional “sample” UI on **nuvelo.one**; keep empty and error states.

### Removed or replaced

| Area | Change |
|------|--------|
| **My adverts** (`web/src/pages/ProfilePage.js`) | Deleted **`MOCK_MY_ADVERTS`** (lamp, bike, services). Removed **Sample** pill, demo rows, and “example listings” banner. **0 ads** → *“You haven't posted any ads yet.”* + **Post your first ad** → `/post`. Listings only from **`fetchListings({ forUserId })`** via `renderProfile` in **`main.js`**. |
| **Notifications** (`main.js` + CSS) | Still loads **`fetchNotificationsForCurrentUser`** (Supabase `notifications`). Empty state copy: *“No notifications yet. We'll let you know when something happens.”* with **🔔** (`.profile-empty-state__icon`). No mock rows or disclaimer. |
| **Performance / stats** (`ProfilePage.js` + `initPerformancePageUi`) | Replaced fake **142 / 87 / 34 / 12** with **0**. Added note: *“Stats will populate once you have active listings.”* Chart is a **flat placeholder** (no sample traffic curve). Period toggles only change label text to *“no data yet”* ranges — not historical dates. |
| **Browse / listings API** (`web/src/lib/listingsApi.js`) | **`demosEnabled()`**: in **production** builds, demo listing merge is **off** unless **`VITE_DEMO_LISTINGS=true`**. Development still defaults to demos unless **`VITE_DEMO_LISTINGS=false`**. Ensures production browse/detail do not inject **`demoListings.js`** mix unless explicitly opted in. |
| **Home** (`buildHomeCategoryGridHtml` / `renderLanding`) | **No category counts** in the category grid (links + labels only). **Trending** uses **`fetchListings({})`** only — no hardcoded featured rows. |
| **Profile hub** | Removed misleading **“New”** badge on **Browse marketplace** (was not data-backed). |

### Stats: real vs zero

- **Performance tab:** All numeric metrics are **0** until a real stats API exists; copy explains they fill in with active listings.
- **No server endpoint** was added for traffic/visitors; numbers are **not** fabricated.

### Hardcoded listing objects

- **Removed** from profile: `MOCK_MY_ADVERTS`.
- **Browse/home** rely on API + optional dev demo merge; **production** defaults to **no** demo merge per `demosEnabled()`.

### Deploy

- **`vercel deploy --prod --force`** (2026-04-15): **READY** — `dpl_By4XU1UtQTisb8fyFMdaezt41f3W`
- **URL:** `https://nuvelo-b6b9nfysi-pmochoki-2021s-projects.vercel.app`
- **Inspector:** `https://vercel.com/pmochoki-2021s-projects/nuvelo/By4XU1UtQTisb8fyFMdaezt41f3W`
- **Production alias:** `https://nuvelo.one`

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

### Admin v2 — DB-backed sections (2026-04-09 follow-up)

Apply migration **`supabase/migrations/20260412130000_admin_moderation_finance_content.sql`** in Supabase (SQL Editor or CLI). RLS policies are **permissive for anon** (demo/admin SPA pattern — tighten for production).

**Wired in `web/admin.html`**

| Nav | Data source |
|-----|-------------|
| Reports queue | `public.moderation_reports` (falls back to `localStorage` demo if no Supabase / table error) |
| Reported listings | Aggregates `moderation_reports` where `target_type = listing` + listing titles from `/api/listings` cache |
| Expired listings | Heuristic: approved listings older than **90 days** (no `expires_at` on listings API model yet) |
| Flagged users | `public.user_flags` + `profiles` names |
| Verification queue | `public.verification_requests` (approve/reject updates row) |
| Banned content | Listings cache with `status = hidden` |
| Appeals | `public.moderation_appeals` |
| Revenue / Boost purchases | `public.boost_purchases` (KPIs, table, weekly chart) |
| Boost (nav) | Same table, full list |
| Payouts | `public.payout_requests` |
| Categories | `public.admin_marketplace_categories` CRUD |
| Locations | `public.admin_marketplace_locations` CRUD |
| Admin accounts | `profiles` where `role = admin` |

**Still external / not automatic**

- Real payment provider writes to `boost_purchases` / `payout_requests`.
- Production admin should use **service role** or Edge Functions instead of wide-open RLS.

### Admin rebuild prompt — schema additions (web agent)

Add these columns **if they do not exist** (admin writes; mobile reads for seller/account messaging):

**`public.listings`**

| Column       | Type    | Default | Purpose |
|--------------|---------|---------|---------|
| `admin_note` | TEXT    | —       | Reason shown to seller on rejection / removal |
| `is_featured`| BOOLEAN | `false` | Homepage / feature placement flag |

**`public.profiles`**

| Column             | Type        | Default | Purpose |
|--------------------|-------------|---------|---------|
| `is_suspended`     | BOOLEAN     | `false` | Suspended users: block post/message only (see **NUVELO_MASTER_RULES.md** ADMIN section) |
| `suspension_reason`| TEXT        | —       | Admin detail (optional surfaced to user or support) |
| `suspended_until`  | TIMESTAMPTZ | —       | Optional auto-lift time |

**Migration in repo:** `supabase/migrations/20260419223000_listings_profiles_admin_mobile_columns.sql` — apply in Supabase (SQL Editor or CLI).

### Tables needed for full functionality

- **Required for connected features**:
  - `public.profiles`
  - `public.nuvelo_listings` (or compatible backend admin API)
  - `public.site_config` (migration exists)
- **Admin support (migration `20260412130000`)**:
  - `public.moderation_reports`, `user_flags`, `verification_requests`, `moderation_appeals`, `boost_purchases`, `payout_requests`, `admin_marketplace_categories`, `admin_marketplace_locations`

---

## 2026-04-19 — `NUVELO_MASTER_RULES.md`

- **Added** repo root **`NUVELO_MASTER_RULES.md`** (full Nuvelo master rules for web + Flutter).
- **Deployment:** replaced the old “never push to main / use feature branches” rule with **commit and push directly to `main`**, confirm Vercel deployment before marking tasks done (live checks on **nuvelo.one**).
- **Removed** that bullet from “WHAT CURSOR MUST NEVER DO”; added step 6 under “BEFORE STARTING ANY TASK” pointing at the deployment section.
- **Admin rebuild / Supabase:** documented **`listings.admin_note`**, **`listings.is_featured`**, **`profiles.is_suspended`**, **`suspension_reason`**, **`suspended_until`** in master rules; added **Admin rebuild prompt — schema additions** under **Admin dashboard rebuild** here; migration **`supabase/migrations/20260419223000_listings_profiles_admin_mobile_columns.sql`**.

---

## 2026-04-19 — iOS (Flutter) — App Store prep (agent)

**Done in `mobile/` (iOS + shared `pubspec` for iOS-only tooling)**

- **Bundle ID** `one.nuvelo.app` (Debug / Release / Profile) and **RunnerTests** `one.nuvelo.app.RunnerTests` in `ios/Runner.xcodeproj/project.pbxproj`.
- **Deployment** iOS **13.0** in `Podfile` + `post_install` IPHONEOS for all pods; project file already at 13.0.
- **Info.plist:** display name **Nuvelo**; camera, photo library, photo add, location (when in use) usage strings; **Supabase / OAuth** `CFBundleURLTypes` + `LSApplicationQueriesSchemes` (`https`, `googlechrome`, `fb`); **light status bar** via `UIStatusBarStyle` + `UIViewControllerBasedStatusBarAppearance` = false; `UILaunchStoryboardName` = `LaunchScreen`; `UIBackgroundModes` = `remote-notification` (for APNs / push when enabled).
- **Not used:** `NSUserNotificationUsageDescription` is not a standard iOS notification permission string; iOS uses `UNUserNotificationCenter` (no separate Info.plist string for the system dialog). The old key in the task spec was skipped.
- **AppDelegate:** `UNUserNotificationCenter` auth + `registerForRemoteNotifications` on the main queue; `application(_:open:options:)` forwards to `super` for deep links.
- **Entitlements:** `ios/Runner/Runner.entitlements` with `aps-environment` = `development` (set to **production** in Xcode / for App Store archive as per your team’s push setup).
- **Privacy:** `ios/Runner/PrivacyInfo.xcprivacy` + **Copy Bundle Resources** in Xcode project.
- **Icons & splash:** `assets/images/nuvelo_logo.png` + `nuvelo_icon.png` generated from **`web/public/nuvelo-logo.svg`** via macOS Quick Look thumbnail (1024 PNG); **flutter_launcher_icons** → `remove_alpha_ios`, background `#0D0A1E`; **flutter_native_splash** with `web: false` so repo web isn’t regenerated; **`LaunchScreen.storyboard`** manually extended with centred **“Nice Vibes Only”** label above the home-indicator safe area.
- **Deps:** `flutter_local_notifications` added for future MVP local alerts (Dart init still TODO when product wants it). **`pubspec.yaml` caveat:** after `dart run flutter_native_splash:create`, verify **full `pubspec.yaml`** was not truncated — restore `flutter_launcher_icons` / `flutter_native_splash` blocks and dependencies if the tool strips them.
- **Fastlane templates:** `ios/fastlane/Appfile`, `ios/fastlane/Deliverfile` (placeholders for Apple ID / team).
- **Screenshots:** `ios/screenshots/en-US/` and `hu/` README placeholders with required dimensions (final PNGs from Simulator + seeded listings — manual).
- **Verify:** `flutter build ios --no-codesign` succeeds.

**Manual / Apple Developer (you)**

- [ ] Apple Developer Program + App Store Connect app record for **one.nuvelo.app**.
- [ ] **Signing:** Xcode → Signing & Capabilities → Team; enable **Push Notifications** if using APNs (entitlements already present).
- [ ] **Archive / IPA:** `flutter build ipa --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` (never commit the anon key).
- [ ] **Upload:** Transporter or `xcrun altool` / `notarytool` per current Apple CLI.
- [ ] **Screenshots** for all required device sizes; **privacy nutrition labels** in ASC; **age rating** questionnaire (4+).
- [ ] **Runner.entitlements:** switch `aps-environment` to **production** for distribution if using push.

### App Store submission checklist (copy)

**App Store Connect (manual)**

- [ ] Apple Developer account active ($99/year)
- [ ] App created in App Store Connect
- [ ] Bundle ID registered: **one.nuvelo.app**
- [ ] Banking / tax if selling digital goods later
- [ ] Privacy policy URL live: **https://nuvelo.one/privacy**

**App content (repo + you)**

- [ ] App icon 1024×1024 no unintended transparency (icons regenerated with solid background)
- [ ] Screenshots for 6.9", 6.5", 5.5", 12.9" iPad
- [ ] Descriptions EN + HU (draft in `ios/fastlane/Deliverfile`)
- [ ] Keywords EN + HU
- [ ] Age rating (4+)
- [ ] Privacy nutrition labels

**Technical**

- [ ] `flutter build ipa` succeeds
- [ ] No crashes on small / large iPhone + iPad (manual QA)
- [ ] Permission strings present (see Info.plist)
- [ ] `PrivacyInfo.xcprivacy` in app bundle
- [ ] HTTPS only; Supabase anon key via `--dart-define` only

**App Review notes (suggested)**

> Nuvelo is a classifieds marketplace for Hungary’s expat and local community. To test: create an account with any email; browse listings; post a test listing; send a message. Listings are moderated before going live; reporting is available on listings.

---

## Android Flutter app — full-stack shell (2026-04-19)

**Scope:** `mobile/` only; **`/web` untouched** (Vercel still builds `web/dist` only).

**Delivered**

- **Design system:** `lib/core/theme.dart` — brand palette (orange/navy/purple), DM Sans via `google_fonts`, radii; `nuveloThemeDark()` default at first launch (`AppSettingsController` uses `ThemeMode.dark` until user changes Settings).
- **Routing:** `go_router` (`lib/core/router.dart`) — splash → onboarding/home, auth routes, shell with **Home | Browse | Sell (+) | Messages | Profile**, full-screen flows for listing detail, post ad, chat, settings, search.
- **Data:** **`ListingsService`** reads/writes listings via **`https://nuvelo.one/api/listings`** (same approved listings as nuvelo.one when the API uses Supabase). Saved ads use **`SharedPreferences`** (`saved_listing_ids`) until a `saved_listings` table is wired.
- **Supabase:** `supabase_flutter` init (`lib/core/supabase_client.dart`); **`AuthService`** (magic link email, SMS OTP, Google/Facebook OAuth redirect **`one.nuvelo.app://login-callback`**), **`ProfileService`**, **`MessagesService`** (+ Realtime inserts on `messages`), **`NotificationsService`**, **`StorageService`** (upload placeholders without extra options).
- **Localization:** `lib/l10n/app_en.arb` / `app_hu.arb`, `nuvelo_lang` + device locale on first run (`AppSettingsController`).
- **Android:** Package **`one.nuvelo.app`**, **minSdk 21**, **targetSdk 34**, manifest permissions + intent-filter for OAuth callback; **`MainActivity`** moved to **`one.nuvelo.app`** package.

**Release APK**

```bash
cd mobile && flutter build apk --release \
  --dart-define=SUPABASE_URL=https://ahiujuljjbozmfwoqtli.supabase.co \
  --dart-define=SUPABASE_ANON_KEY="<anon key from Vercel VITE_SUPABASE_ANON_KEY / Supabase Dashboard>"
```

Artifact path: **`mobile/build/app/outputs/flutter-apk/app-release.apk`**.

### Post Ad + branding triage (2026-04-19)

**Fix 1 — Step 2 photos**

- **`post_photos_screen.dart`**: eight tappable slots; gallery or camera via `image_picker`; **`permission_handler`** before pick; max 8 files, 5 MB each; slot 0 = **Cover**; upload to Supabase bucket **`listings-images`** at **`listings/{folderTimestamp}-{userId}/{filename}`** through **`StorageService.uploadListingPhoto`** (`XFile`, `userId`, `folderTimestamp`); circular progress overlay while uploading; snackbar + clear slot + retry on failure; **Next** disabled while any upload is in flight.
- **`post_ad_screen.dart`** sends **`images`** as the list of public URLs on **`createListing`** (no second-round upload).

**Fix 2 — Category-specific `categoryFields`**

- **`post_category_fields.dart`** drives extras by **`categoryId`**: **Rentals** (property type, bedrooms/bathrooms steppers, area m², furnished/bills/pets/parking, available-from tied to shared listing date); **Vehicles**; **Jobs**; **Events** (date/time pickers, paid toggle + price, etc.); **Donations**; **default** chips + brand + quantity for electronics, furniture, fashion, goods, babies-kids, services, other.
- Submit merges **`availabilityDate`**, **`preferredContactMinutes`**, and extras into **`categoryFields`** (nulls stripped). Rentals hide the duplicate **Availability date** row (that date lives in the rentals block).

**Fix 3 — Launcher icon + splash**

- **`flutter_launcher_icons`** + **`flutter_native_splash`** in **`mobile/pubspec.yaml`** (Android only per config).
- Raster sources: **`mobile/tool/gen_brand_pngs.dart`** generates **`assets/images/nuvelo_icon.png`** and **`nuvelo_logo.png`** (placeholder orange circle on transparent until a final brand export replaces them).
- Commands used: **`dart run tool/gen_brand_pngs.dart`**, **`dart run flutter_launcher_icons`**, **`dart run flutter_native_splash:create`** — mipmaps under **`mobile/android/app/src/main/res/mipmap-*`**, adaptive foreground/background, splash + Android 12 splash assets.

**Release APK (agent build)**

- Built with **`assets/env`** sourced so **`SUPABASE_ANON_KEY`** is injected via **`--dart-define`** (do not commit keys).
- **Result:** success — **`mobile/build/app/outputs/flutter-apk/app-release.apk`** (~60.6 MB). Gradle printed **javac** “source/target value 8 is obsolete” warnings from the toolchain; **`flutter analyze`** reported **no issues** before the build.

**MANUAL STEP NEEDED:** Supabase Dashboard → **Authentication** → **URL Configuration** → **Redirect URLs** → add **`one.nuvelo.app://login-callback`** so OAuth matches the app intent-filter.

### iOS UX polish (NuveloScreen + flows, 2026-04-19)

- **`NuveloScreen`** (`mobile/lib/widgets/nuvelo_screen.dart`): **`Color(0xFF0D0A1E)`** scaffold background, configurable **SafeArea** edges (shell tabs use `safeTop`/`safeBottom` false to avoid double insets under `MainShell`), **tap outside** unfocuses inputs.
- **Splash / onboarding / auth** (sign-in, verify OTP, register): wrapped with **NuveloScreen**; OTP uses **SingleChildScrollView** for keyboard.
- **Home & browse**: **NuveloScreen** around body (same shell as Android).
- **Listing detail**: navy loading/error; **Send message** → **`MessagesService.getOrCreateThread`** → **`/messages/:tid/chat`**; localized **`thisIsYourListing`** (`app_en.arb` / `app_hu.arb`).
- **Post ad (3 steps)**: step 1 includes core fields plus **category-specific extras** (**`PostCategoryFieldsSection`**), **CupertinoTimerPicker** (preferred contact time), and (non-rentals) **CupertinoDatePicker** / Material date for availability; step 2 **`PostPhotosScreen`** (eight slots, Supabase uploads before submit); step 3 review + publish with **`images`** + merged **`categoryFields`**.
- **Profile** (6 tabs): **NuveloScreen** wrapper on the tab root.
- **Chat**: **NuveloScreen** + input row padded with **`MediaQuery.paddingOf(context).bottom`** (home indicator).
- **Settings**: **profile photo** (gallery → **`StorageService.uploadAvatar`** + **`ProfileService.updateProfile`**), language + theme toggles.

**Build:** `cd mobile && flutter build ios --no-codesign` succeeds after changes.

**IPA (manual secrets + signing):**

```bash
cd mobile && flutter build ipa --release \
  --dart-define=SUPABASE_URL=https://ahiujuljjbozmfwoqtli.supabase.co \
  --dart-define=SUPABASE_ANON_KEY="<your anon JWT from Vercel / Supabase — never commit>"
```

Output (when signing succeeds): **`mobile/build/ios/ipa/`** — e.g. **`Nuvelo.ipa`** or **`Runner.ipa`** depending on Xcode product name.

**Simulator QA checklist** (requires local env with anon key in `assets/env` or `--dart-define`): email OTP → browse (`nuvelo.one` API listings) → post listing → message thread realtime → profile photo → HU locale — **not executed in agent** (no Simulator run here).

**Still to deepen (when you iterate)**

- Replace placeholder **`nuvelo_icon.png` / `nuvelo_logo.png`** with final brand exports (re-run **`dart run flutter_launcher_icons`** and **`dart run flutter_native_splash:create`**).
- Tune **Gradle/Java** toolchain warnings (obsolete `-source 8` / `-target 8`) when upgrading Android Gradle Plugin.
