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

## 1. Phone verification (Twilio) — **PAUSED**

SMS verification is **on hold** until Nuvelo has budget for Twilio (paid number + monthly fees). Users can still **save a phone number** in Profile → Settings; SMS send/verify UI is hidden.

When you’re ready later: enable **Phone** in Supabase with Twilio SID/token/messaging service, then re-enable the verify block in the app.

---

## 2. Continue with Apple

### Your Apple IDs (from Developer portal)

| What | Value |
|------|--------|
| **Team ID** | `H9JAV8HGW9` |
| **App bundle ID** | `one.nuvelo.app` |
| **Sign in with Apple key** | `Nuvelo sign in` |
| **Key ID** | `FX25BH5D5X` |
| **Private key file** | `AuthKey_FX25BH5D5X.p8` (download once; store safely) |

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

From the repo root (Node 18+):

```bash
node scripts/generate-apple-client-secret.mjs \
  --team-id H9JAV8HGW9 \
  --key-id FX25BH5D5X \
  --client-id one.nuvelo.web \
  --p8 ~/Downloads/AuthKey_FX25BH5D5X.p8
```

Replace `--client-id` with the **Services ID** you created (not `Nuvelo` and not only the bundle ID).

Copy the printed JWT.

### Step C — Supabase

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
