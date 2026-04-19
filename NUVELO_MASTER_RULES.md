# NUVELO MASTER RULES
# Read this entire file before writing a single line of code.
# These rules apply to ALL agents — web, Android (Flutter), and iOS (Flutter).

---

## THE GOLDEN RULE
There is ONE Supabase project. ONE database. ONE source of truth.
Web, Android, and iOS all read from and write to the exact same tables.
NEVER create a separate database, duplicate tables, or a separate backend
for any platform. If a user posts an ad on the website, it must appear
in the Android app and iOS app instantly — and vice versa.

---

## SUPABASE PROJECT (shared by ALL platforms)

Project ID:   ahiujuljjbozmfwoqtli
Project URL:  https://ahiujuljjbozmfwoqtli.supabase.co
Anon key:     stored in Vercel env as VITE_SUPABASE_ANON_KEY
              stored in Flutter as --dart-define=SUPABASE_ANON_KEY
              NEVER hardcode the key in any committed file
              NEVER put it in a public GitHub repo

Auth:         Supabase Auth (email, phone/SMS, Google, Facebook)
Storage:      Supabase Storage
              - Bucket: avatars        → user profile photos
              - Bucket: listings-images → listing photos
Realtime:     Supabase Realtime for messages and notifications

---

## PLATFORM AGENTS & THEIR SCOPE

### Agent 1 — Web (Vanilla JS + Vite + Vercel)
Repo folder:  /web
Deployed at:  https://nuvelo.one
Stack:        Vanilla JS, Vite, Vercel (static + serverless functions)
Supabase SDK: @supabase/supabase-js (browser)
Rules:
- All API calls go directly to Supabase from the browser
- Backend listings API is at LISTINGS_BACKEND_URL on Render
  (used for legacy listing operations until fully migrated to Supabase)
- Admin dashboard is at /admin.html (password: nuvelo-admin, SHA-256 hashed)
- NEVER touch Flutter files
- NEVER touch /mobile folder

### Agent 2 — Android App (Flutter)
Repo folder:  /mobile
Platform:     Android
Stack:        Flutter, supabase_flutter package
Package name: one.nuvelo.app
Rules:
- Use supabase_flutter for all auth and database calls
- Initialize Supabase with the project URL and anon key above
- NEVER create new Supabase tables — use only existing ones
- NEVER touch /web folder
- NEVER touch iOS-specific files (Runner.xcworkspace, Info.plist etc)
- Target API level: Android 21+ (minSdkVersion 21)

### Agent 3 — iOS App (Flutter)
Repo folder:  /mobile (same Flutter codebase as Android)
Platform:     iOS
Stack:        Flutter, supabase_flutter package
Bundle ID:    one.nuvelo.app
Rules:
- Same Flutter codebase as Android — do NOT create a separate project
- Use supabase_flutter identical to Android agent
- NEVER touch /web folder
- NEVER touch Android-specific files (build.gradle, AndroidManifest.xml etc)
- Minimum iOS deployment target: iOS 13.0

---

## DATABASE TABLES (shared — do NOT duplicate or rename)

Use these exact table names. If a table doesn't exist yet, create it
once and document it here. Never create platform-specific versions
like listings_mobile or listings_web — there is only listings.

| Table              | Purpose                                    |
|--------------------|--------------------------------------------|
| listings           | All ads posted on any platform             |
| profiles           | User profiles (extends auth.users)         |
| message_threads    | Conversation threads between users         |
| messages           | Individual messages within threads         |
| notifications      | In-app notifications for all users         |
| saved_listings     | User's saved/favourited ads                |
| listing_views      | View count tracking per listing            |
| feedback           | Seller feedback/reviews                    |
| reports            | User reports on listings or users          |
| site_config        | Admin-controlled site settings             |
| boosts             | Paid listing boost records                 |

Key listing fields (always use these exact names):
  id, title, description, price, category, subcategory,
  city, district, condition, photos (array),
  seller_name, seller_phone, seller_email,
  seller_whatsapp (boolean), contact_preference,
  status (active/pending_review/rejected/expired/banned),
  admin_note (text — reason shown to seller when rejected/banned),
  is_featured (boolean — homepage/feature flag, default false),
  user_id, posted_by_admin (boolean),
  created_at, updated_at, expires_at,
  view_count, language (en/hu)

Key profile fields (admin + mobile awareness):
  is_suspended (boolean, default false),
  suspension_reason (text, optional),
  suspended_until (timestamptz, optional)

---

## AUTH RULES (all platforms)

- Auth provider: Supabase Auth
- Supported methods: Email magic link, Phone/SMS OTP, Google OAuth, Facebook OAuth
- After sign-in: always upsert a row in public.profiles with user_id, 
  display_name, role, phone, email, avatar_url
- User roles: buyer, tenant, seller, agent, landlord
- JWT tokens: let Supabase handle — never manually create tokens
- RLS (Row Level Security): ALWAYS enabled on every table
  Standard policies:
  - Users can read their own data
  - Users can only edit/delete their own listings and profile
  - Public can read listings where status = 'active'
  - Admins (service role) can do everything

---

## ADMIN

### ADMIN STRATEGY — THREE PLATFORM RULE

Admin dashboard lives ONLY at nuvelo.one/admin.html  
Never build admin screens into Android or iOS apps.  
All admin actions write to Supabase and instantly affect all three platforms.

Mobile apps need these two admin-aware features only:

#### 1. LISTING STATUS AWARENESS

If a listing `status` is `'rejected'` or `'banned'`, show the owner a clear message in their My Ads tab:

"This listing was removed. Reason: [admin_note]"

Never just silently hide it.

#### 2. ACCOUNT SUSPENSION AWARENESS

If a user account is suspended (add `is_suspended` boolean to `profiles` table), on app launch show:

"Your account has been suspended. Contact support@nuvelo.one"

Block access to post/message features only. They can still browse listings.

Everything else — approvals, bans, reports, revenue, settings — is handled exclusively from the web admin.

---

## STORAGE RULES

Bucket: avatars
  Path format:    avatars/{user_id}/avatar.{ext}
  Public read:    true
  Max size:       5MB
  Allowed types:  image/jpeg, image/png, image/webp

Bucket: listings-images
  Path format:    listings/{listing_id}/{filename}
  Public read:    true
  Max size:       5MB per image, max 8 images per listing
  Allowed types:  image/jpeg, image/png, image/webp

---

## DESIGN & BRAND

Brand name:     Nuvelo
Tagline:        Nice Vibes Only
Domain:         nuvelo.one
Support email:  support@nuvelo.one

Colors:
  Primary orange:   #f97316  (buttons, CTAs, active states)
  Dark navy bg:     #0D0A1E  (main background)
  Card bg:          #13102A  (cards, panels)
  Deep card:        #1E1A35  (secondary cards)
  Purple accent:    #7C3AED / #8B5CF6  (highlights, badges)
  Text primary:     #F1F5F9
  Text muted:       #94A3B8
  Border:           #2A3347
  Success:          #22C55E
  Warning:          #F59E0B
  Danger:           #EF4444

Typography:
  Web:     DM Sans, system-ui, sans-serif
  Mobile:  Use Google Fonts DM Sans via flutter_google_fonts package

Logo files:
  /web/public/nuvelo-logo.svg    (full wordmark)
  /web/public/nuvelo-icon.svg    (icon/favicon — crescent moon symbol)

---

## LANGUAGES

The platform supports English and Hungarian.
  Default:  English
  Second:   Hungarian (Magyar)
  Auto-detect browser/device language on first visit
  User preference stored in: localStorage (web) / SharedPreferences (mobile)
  Translation approach: DOM-walker on web, ARB files on Flutter

---

## CATEGORIES (use exact strings in DB)

Trending, Events, Donations, Rentals, Jobs, Services,
Goods & Items, Vehicles, Electronics, Furniture & Home,
Fashion, Babies & Kids, Other

---

## CURRENCY & NUMBER FORMATTING

Currency:   HUF (Hungarian Forint)
Format EN:  100,000 HUF
Format HU:  100 000 Ft
Always use Intl.NumberFormat (web) or NumberFormat (Flutter intl package)
Never display raw unformatted numbers like 100000

---

## DEPLOYMENT (Git → Vercel)

Deployment rule: Always commit and push directly to **main**. Vercel is connected to **main** and auto-deploys on every push. After every task, push to **main** and confirm the Vercel deployment succeeded before marking the task done. This lets you check progress live on **nuvelo.one** after each change.

---

## WHAT CURSOR MUST NEVER DO

- NEVER create a separate Supabase project for any platform
- NEVER duplicate a table for mobile vs web
- NEVER hardcode the Supabase anon key in committed code
- NEVER use a different database for listings (e.g. Firebase, SQLite cloud)
- NEVER rename existing tables or columns without updating ALL platforms
- NEVER remove RLS from any table
- NEVER delete data without a confirmation step
- NEVER show raw Supabase error messages to end users

---

## BEFORE STARTING ANY TASK

1. Read this file ✓
2. Check what platform you are working on (web / android / ios)
3. Confirm you are only touching files for your platform
4. If you need to create or alter a Supabase table, check this file 
   first — if the table already exists, ALTER it, never recreate it
5. Update CURSOR_NOTES.md when done with what you changed
6. Push to **main** and confirm Vercel deployment before marking the task done (see **DEPLOYMENT** above)

---

## ENVIRONMENT VARIABLES

Web (Vercel):
  VITE_SUPABASE_URL         = https://ahiujuljjbozmfwoqtli.supabase.co
  VITE_SUPABASE_ANON_KEY    = [in Vercel dashboard]
  LISTINGS_BACKEND_URL      = https://nuvelo-backend.onrender.com
  PRERENDER_TOKEN           = [in Vercel dashboard — sign up at prerender.io]

Flutter (both platforms):
  SUPABASE_URL              = https://ahiujuljjbozmfwoqtli.supabase.co
  SUPABASE_ANON_KEY         = [use --dart-define or .env file, never commit]

Pass Flutter env vars at build time:
  flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  OR use flutter_dotenv package with a .env file added to .gitignore

---
Last updated: 2026-04-19 (admin schema: listings + profiles)
Maintained by: Paul Ochoki
Project: Nuvelo (nuvelo.one)
