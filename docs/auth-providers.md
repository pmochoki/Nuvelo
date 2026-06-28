# Nuvelo auth providers & branded email

Supabase project: `ahiujuljjbozmfwoqtli`  
Production site: `https://nuvelo.one`  
Auth callback (all OAuth): `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`

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

### Step C — Supabase (dashboard or one command)

**Option A — automatic (recommended if dashboard paste keeps failing)**

1. Create a personal access token: [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens)
2. Run once in Terminal:

```bash
cd ~/Desktop/Nuvelo-fresh
SUPABASE_ACCESS_TOKEN=sbp_paste_your_token_here node scripts/configure-supabase-apple.mjs
```

This generates a fresh JWT and writes it to Supabase via the Management API (`external_apple_client_id` + `external_apple_secret`).

**Option B — manual dashboard**

**Authentication → Providers → Apple**

| Field | What to paste |
|-------|----------------|
| **Enable** | ON |
| **Client IDs** | `one.nuvelo.web` (Services ID). Optionally add `one.nuvelo.app` comma-separated for the native app later. |
| **Secret Key** | The **JWT** from the script (starts with `eyJ…`) |

Save.

**Reminder:** Apple JWT secrets expire (~6 months). Regenerate with the same script and update Supabase before expiry.

### Test

nuvelo.one → Sign in → **Continue with Apple**.

---

## 3. Continue with Facebook (Meta)

When Meta is ready:

- **OAuth redirect URI:** `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
- **Supabase → Providers → Facebook** → App ID + App Secret → Enable

---

## 4. Continue with Google

1. [Google Cloud Console](https://console.cloud.google.com) → OAuth client (Web)
2. Redirect URI: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
3. **Supabase → Providers → Google** → Client ID + Secret → Enable

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
| Apple | Services ID + JWT in Supabase |
| Facebook | Meta app (in progress) |
| Google | Enable in Supabase |
| Branded email | Custom SMTP + DNS |
