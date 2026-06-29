# Nuvelo auth providers & branded email

Supabase project: `ahiujuljjbozmfwoqtli`  
Production site: `https://nuvelo.one`  
Auth callback (all OAuth): `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`

## Sign-in / sign-up readiness (production)

| Method | App wired | Supabase enabled | Public ready |
|--------|-----------|------------------|--------------|
| **Email + password** | Yes | Yes | Yes — use Registration on nuvelo.one |
| **Google** | Yes | Yes | Yes |
| **Apple** | Yes | Yes | Yes |
| **Facebook** | Yes | Yes | **After Meta App Review + Live** — see [`docs/META_APP_REVIEW.md`](META_APP_REVIEW.md) |

Forgot password → `/reset-password`. Phone SMS is off until Twilio is configured.

**Supabase → Authentication → URL Configuration**

| Setting | Value |
|--------|--------|
| Site URL | `https://nuvelo.one` |
| Redirect URLs | `https://nuvelo.one/**`, `one.nuvelo.app://login-callback` |

---

## 1. Phone verification — **removed for now**

No phone fields or SMS in the app until Twilio budget is ready. Sign-in is **Google, Apple, Facebook, or email + password** only.

---

## 2. Continue with Apple

### Your Apple IDs (from Developer portal)

| What | Value |
|------|--------|
| **Team ID** | `H9JAV8HGW9` |
| **App bundle ID** | `one.nuvelo.app` |
| **Sign in with Apple key** | `Nuvelo sign in` |
| **Key ID** | `FX25BH5D5X` |
| **Private key file** | `AuthKey_FX25BH5D5X.p8` on Desktop |

### The `.p8` file is not an app

macOS may say *“no application set to open .p8”* — that’s normal. The `.p8` is a **text private key**. Open it with **TextEdit**, **Cursor**, or **VS Code** (right‑click → Open With). **Do not paste the whole `.p8` into Supabase.**

### What is a JWT?

A **JWT** (JSON Web Token) is a long single-line string like:

`eyJhbGciOiJFUzI1NiIs...`

Apple requires a **client secret** that is a JWT **signed** with your `.p8` key. Supabase’s **Secret Key** field wants that JWT — not the Key ID, not the raw `.p8` contents.

### Step A — Create a **Services ID** (required for web)

Your **bundle ID** (`one.nuvelo.app`) is for the iOS app. **Web** sign-in needs a separate **Services ID**:

1. [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles → Identifiers**
2. **+** → choose **Services IDs** → Continue
3. Description: `Nuvelo Web Sign In`
4. Identifier: e.g. **`one.nuvelo.web`** (reverse-domain style)
5. Enable **Sign in with Apple** → Configure:
   - **Domains**: `nuvelo.one`, `ahiujuljjbozmfwoqtli.supabase.co`
   - **Return URLs**: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
6. Save

### Step B — Generate the JWT (client secret)

**You don’t download a JWT from Apple.** You **create** it with the script in this repo.

1. Open **Terminal** in Cursor: menu **Terminal → New Terminal**
2. Paste this command (uses the `.p8` in your Downloads folder):

```bash
cd ~/Desktop/Nuvelo-fresh && node scripts/generate-apple-client-secret.mjs \
  --team-id H9JAV8HGW9 \
  --key-id FX25BH5D5X \
  --client-id one.nuvelo.web \
  --p8 ~/Desktop/AuthKey_FX25BH5D5X.p8
```

If your key is **`FX25BH5D5X`** instead, change `--key-id` and `--p8` to match `AuthKey_FX25BH5D5X.p8`.

3. The output is a **long line starting with `eyJ`** — that **is** the JWT. Copy the whole line.
4. A copy was also saved to **`~/Desktop/nuvelo-apple-jwt.txt`** for easy paste into Supabase.

**Wrong:** pasting the `.p8` file contents (`MIGTAgEA…`) or the Key ID alone.  
**Right:** the one-line `eyJ…` string from the script.

### Step C — Supabase

**Web (`nuvelo.one`)** uses Apple’s JS popup + `signInWithIdToken` — **no OAuth JWT secret required** for browser sign-in. You only need:

**Authentication → Providers → Apple**

| Field | Value |
|-------|--------|
| **Enable** | ON |
| **Client IDs** | `one.nuvelo.web` (Services ID). Optionally add `one.nuvelo.app` for the native app. |
| **Secret Key** | Optional for web (leave empty or set via script for native/OAuth fallback). |

In **Apple Developer → Services ID → Sign in with Apple → Configure**, add **Return URLs**:

- `https://nuvelo.one`
- `https://nuvelo.one/api/auth/apple-callback` (**required for iPhone Safari** — Apple `form_post` return)

(alongside the Supabase callback URL for any OAuth/mobile flows).

**Option A — automatic JWT (native app / OAuth fallback only)**

1. Create a personal access token: [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)
2. Run once in Terminal:

```bash
cd ~/Desktop/Nuvelo-fresh
SUPABASE_ACCESS_TOKEN=sbp_paste_your_token_here node scripts/configure-supabase-apple.mjs
```

This generates a fresh JWT and writes it to Supabase via the Management API (`external_apple_client_id` + `external_apple_secret`). **Not required for web** after the `signInWithIdToken` change.

**Option B — manual dashboard JWT paste (avoid)**

⚠️ Supabase’s Secret Key field can **truncate** the JWT (~120 chars), which causes `invalid_client` on OAuth redirect flows. Prefer leaving Secret Key empty for web-only, or use **Option A** if you need OAuth.

### Test

nuvelo.one → Sign in → **Continue with Apple**.

**Mobile (iPhone Safari, Chrome phone view):** uses Apple **form_post** via `/api/auth/apple-callback` and `signInWithIdToken` — **no Supabase OAuth secret required**. Do **not** use `signInWithOAuth` for Apple on web unless you have pasted a valid Apple JWT secret in Supabase.

---

## 3. Continue with Facebook (Meta)

### Activation status (verified 2026-06-28)

| Layer | Status |
|-------|--------|
| **Nuvelo web app** | Wired — `Continue with Facebook` → Supabase OAuth |
| **Supabase** | Facebook provider **enabled**, App ID `4426473634349036`, callback configured |
| **Meta redirect URI** | Saved — `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback` |
| **Meta Basic settings** | App domains, privacy, terms, category filled |
| **Meta app mode** | **Unpublished** — only Admins / Developers / **Testers** can sign in until you **Publish** |
| **Your Nuvelo Entreprises account** | **Cannot work** — business/Page profile does not share email to apps |
| **Public customers** | Blocked until app is **Live** (+ Meta business verification / App Review for `email` if prompted) |

**To prove Facebook login works today:** add your **personal** Facebook as **App roles → Testers**, open Chrome **incognito**, log into facebook.com with that personal account, then **Continue with Facebook** on nuvelo.one.

**To enable all customers:** Meta Developer → **Publish** → complete **Business verification** → submit **App Review** for `email` if required → switch app **Live**.

**Step-by-step App Review copy-paste text:** see [`docs/META_APP_REVIEW.md`](META_APP_REVIEW.md).

The **web app is already wired** — same OAuth redirect flow as Google. You only need a Meta app + Supabase credentials.

### Callback URL (copy exactly)

```
https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback
```

### Step A — Create a Meta app

1. [developers.facebook.com](https://developers.facebook.com) → **My Apps** → **Create App**
2. Use case: **Authenticate and request data from users with Facebook Login** (or **Other** → Consumer)
3. App name: e.g. **Nuvelo** → Create app

### Step B — Add Facebook Login

1. App dashboard → **Add Product** → **Facebook Login** → **Set Up** → choose **Web**
2. **Facebook Login → Settings** (left sidebar under Facebook Login)
3. **Valid OAuth Redirect URIs** — add exactly:

   `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`

4. Save changes

### Step C — App settings (Basic)

**Settings → Basic**

| Field | Value |
|-------|--------|
| **App Domains** | `nuvelo.one` |
| **Privacy Policy URL** | `https://nuvelo.one/privacy` |
| **Terms of Service URL** (optional) | `https://nuvelo.one/terms` |
| **User data deletion** | `https://nuvelo.one/privacy` or your data-deletion page |
| **Category** | e.g. Shopping |

Copy **App ID** and **App Secret** (click Show).

### Step D — Supabase

**Option A — one command (recommended)**

```bash
cd ~/Desktop/Nuvelo-fresh
FACEBOOK_APP_ID=your_app_id \
FACEBOOK_APP_SECRET=your_app_secret \
SUPABASE_ACCESS_TOKEN=sbp_your_token \
node scripts/configure-supabase-facebook.mjs
```

**Option B — dashboard**

**Authentication → Providers → Facebook**

| Field | Value |
|-------|--------|
| **Enable** | ON |
| **Facebook client ID** | Meta **App ID** |
| **Facebook client secret** | Meta **App Secret** |

### Step E — Development vs Live mode

| Mode | Who can sign in |
|------|-----------------|
| **Development** | Only Meta app **Admins**, **Developers**, and **Testers** you add under App roles |
| **Live** | Any Facebook user (required for public launch) |

While testing in Development mode, add your Facebook account under **App roles → Testers** (or as Admin).

To go **Live**: App Review may require **email** permission approval. For login, `public_profile` + `email` are standard — submit if Meta prompts you.

### Test

1. Hard-refresh [nuvelo.one](https://nuvelo.one)
2. **Sign in → Continue with Facebook**
3. Approve permissions → you return to nuvelo.one signed in

**Common errors**

| Error | Fix |
|-------|-----|
| “Facebook sign-in is not available yet” | Enable Facebook in Supabase (Step D) |
| “URL blocked” / redirect mismatch | Add exact Supabase callback URL in Meta (Step B) |
| Works for you only, not others | Meta app still in Development — switch to Live or add testers |
| **“Error getting user email from external provider”** / dialog says **“Continue as Nuvelo”** | You are signed into Facebook as a **business or Page profile** (e.g. Nuvelo Entreprises). Meta does **not** share an email for those profiles, and Supabase requires an email. **Fix:** switch to your **personal** Facebook profile, then retry (see below). |

### Business / Page profile (“Nuvelo Entreprises”) — why login always fails

If Facebook shows **“Continue as Nuvelo”** or your top-right account is **Nuvelo Entreprises**, you are **not** using a personal Facebook account. Nuvelo’s integration is working; Facebook simply returns **no email** for business/Page identities.

Meta syncs your **active profile** across laptop and phone via [Accounts Center](https://accountscenter.facebook.com/profiles), so every device keeps picking the same business profile until you switch.

**Fix (do all of these once):**

1. Open [Accounts Center → Profiles](https://accountscenter.facebook.com/profiles) on **phone and laptop**.
2. Switch the **active profile** to your **personal** name (not Nuvelo Entreprises / your Page).
3. Confirm facebook.com top-right shows your **personal** name.
4. Remove Nuvelo: [Facebook → Settings → Apps and websites](https://www.facebook.com/settings?tab=applications) → **Nuvelo** → Remove.
5. Hard-refresh [nuvelo.one](https://nuvelo.one) → **Continue with Facebook**. The dialog should say **“Continue as [Your Name]”**, not “Continue as Nuvelo”.

**Quick test in a clean session:** open a **private/incognito** window → log into facebook.com with your **personal** account only → then sign in on nuvelo.one with Facebook.

**Alternative:** use **Google** or **email + password** on Nuvelo; use Facebook login only with personal profiles.

### I only have “Nuvelo Entreprises” — no personal Facebook profile

If [Accounts Center → Profiles](https://accountscenter.facebook.com/profiles) lists **only** Nuvelo Entreprises (and Instagram/Threads/WhatsApp), you **cannot switch** to a personal profile that does not exist. Facebook login for Nuvelo will keep using Nuvelo Entreprises and **will not share an email** — that is expected.

**Your options:**

| Goal | What to do |
|------|------------|
| **Sign into Nuvelo yourself** | Use **Google**, **Apple**, or **email + password** on nuvelo.one — skip Facebook for your own account. |
| **Test that Facebook login works** | Meta Developer → your app → **App roles → Test Users** → Create → log into facebook.com as that test user (incognito) → try Nuvelo. |
| **Use Facebook login with a real personal account** | **Create** a personal Facebook account at [facebook.com/r.php](https://www.facebook.com/r.php) (your real name, not “Nuvelo Entreprises”), then **App roles → Testers** add that account while the app is in Development mode. Or click **Add accounts** in Accounts Center and sign in with a different Facebook login you already own. |
| **Let customers use Facebook** | Normal buyers/sellers with **personal** Facebook accounts will work once the app is **Live** (and email permission is approved if Meta requires it). Your business-only Facebook identity is a special case. |

Contact info in Accounts Center (`nuveloworld@gmail.com`) is **not** the same as Facebook sharing email to apps when you authenticate as a Page/business profile.
| No email returned | Request `email` scope (already set in app code); approve in App Review for Live |

---

## 4. Continue with Google

1. [Google Cloud Console](https://console.cloud.google.com) → OAuth client (Web)
2. Redirect URI: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
3. **Supabase → Providers → Google** → Client ID + Secret → Enable

### Hide the random `*.supabase.co` URL on Google sign-in

Google shows the **OAuth callback host**. With the default project URL, users see  
`ahiujuljjbozmfwoqtli.supabase.co`. To change that:

| Option | Cost | Google shows | Notes |
|--------|------|--------------|--------|
| **Vanity subdomain** | **Pro plan** (~$25/mo), no add-on | `nuvelo.supabase.co` | Cheaper than custom domain; CLI only |
| **Custom domain** | Pro + **$10/mo** add-on + DNS | `api.nuvelo.one` | Best branding; see `scripts/setup-supabase-custom-domain.sh` |
| **Free plan only** | $0 | Still `ahiujuljjbozmfwoqtli.supabase.co` | Improve **OAuth consent screen** (app name + logo); domain line unchanged |

**Vanity subdomain (recommended if Pro but not custom-domain add-on)**

1. Upgrade org to **Pro** (Dashboard → Billing).
2. On your machine: `supabase login`
3. Run from repo root:
   ```bash
   chmod +x scripts/setup-supabase-vanity-subdomain.sh
   ./scripts/setup-supabase-vanity-subdomain.sh check
   ```
4. In **Google Cloud** (and Meta / Apple), add redirect URI **before** activate:
   - `https://nuvelo.supabase.co/auth/v1/callback`
   - Keep the old `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback` until clients are migrated.
5. `./scripts/setup-supabase-vanity-subdomain.sh activate`
6. **Vercel** → `VITE_SUPABASE_URL=https://nuvelo.supabase.co` (same anon key) → redeploy.
7. **Mobile** → `assets/env` `SUPABASE_URL=https://nuvelo.supabase.co`

**Free plan — polish only (no domain change)**

[Google Cloud Console](https://console.cloud.google.com) → **OAuth consent screen**:

- App name: **Nuvelo**
- App logo + support email
- Authorized domains: `nuvelo.one`

Users still see the Supabase project host on the “Continue to …” line until you enable vanity or custom domain.

---

## 5. Branded email (“Nuvelo” not “Supabase”)

Use **Custom SMTP** (Resend, SendGrid, Postmark, etc.) + verify `nuvelo.one` DNS.

**Supabase → Authentication → Emails → SMTP** → sender `Nuvelo <no-reply@nuvelo.one>`  
Edit email templates to say “Nuvelo” in subjects/bodies.

---

## Quick checklist

| Feature | Status |
|--------|--------|
| Phone SMS | **Paused** (Twilio cost) |
| Apple | Services ID + Supabase Client ID (web uses Apple JS popup) |
| Facebook | Meta app + App ID/Secret in Supabase |
| Google | Enable in Supabase |
| Branded email | Custom SMTP + DNS |
