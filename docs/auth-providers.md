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

## 1. Phone verification (Twilio)

Used on **Profile → Settings** (not on the sign-in modal). Flow: user enters `+36` mobile → **Send verification code** → enters SMS OTP → **Verify number**.

### Twilio

1. [twilio.com](https://www.twilio.com) → create account (trial works for testing).
2. **Console → Account** → copy **Account SID** and **Auth Token**.
3. **Messaging → Services** → create a **Messaging Service** (or use a Twilio phone number) → copy **Messaging Service SID** (`MG…`).
4. For Hungary: ensure SMS to `+36` is allowed on your Twilio account (trial may require verified recipient numbers).

### Supabase

1. **Authentication → Providers → Phone** → Enable.
2. Choose **Twilio** and paste Account SID, Auth Token, Messaging Service SID.
3. Save.

### Test

1. Sign in on nuvelo.one.
2. Go to `/profile/settings`.
3. Enter a Hungarian mobile (8–9 digits after +36) → **Send verification code** → enter OTP → **Verify number**.

If SMS fails, check Supabase **Authentication → Logs** and Twilio **Monitor → Logs**.

---

## 2. Continue with Apple

### Apple Developer

1. [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles**.
2. **Identifiers → App IDs** — note your iOS bundle ID (`one.nuvelo.app` or similar).
3. **Identifiers → Services IDs** → **+** → create e.g. `one.nuvelo.web` → enable **Sign in with Apple** → configure:
   - **Domains**: `nuvelo.one`, `ahiujuljjbozmfwoqtli.supabase.co`
   - **Return URLs**: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
4. **Keys → +** → enable **Sign in with Apple** → download `.p8` (once) → note **Key ID**.
5. Note **Team ID** (top-right of developer portal).

### Supabase

1. **Authentication → Providers → Apple** → Enable.
2. **Services ID** (client ID), **Secret Key** (contents of `.p8`), **Key ID**, **Team ID**.
3. Save.

### Web app

The sign-in modal already has **Continue with Apple** (`signInWithOAuth({ provider: 'apple' })`). No extra redirect URL beyond the global callback.

---

## 3. Continue with Facebook (Meta)

You’re setting up Meta separately. When ready:

### Meta for Developers

1. [developers.facebook.com](https://developers.facebook.com) → **My Apps → Create App** (type: Consumer).
2. Add **Facebook Login** product.
3. **Facebook Login → Settings**:
   - Valid OAuth Redirect URIs: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
4. **Settings → Basic** → copy **App ID** and **App Secret**.
5. Switch app to **Live** when ready (requires privacy policy URL — e.g. `https://nuvelo.one/privacy`).

### Supabase

1. **Authentication → Providers → Facebook** → Enable → App ID + App Secret.
2. Save.

---

## 4. Continue with Google

### Google Cloud Console

1. [console.cloud.google.com](https://console.cloud.google.com) → APIs & Services → **Credentials**.
2. **OAuth 2.0 Client ID** (Web application):
   - **Authorized JavaScript origins**: `https://nuvelo.one`, `http://localhost:5173` (local dev)
   - **Authorized redirect URIs**: `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback`
3. Copy **Client ID** and **Client Secret**.

### Supabase

1. **Authentication → Providers → Google** → Enable → paste Client ID + Secret.
2. Save.

### Verify

1. Open nuvelo.one → Sign in → **Continue with Google**.
2. If provider is disabled, the app shows a clear setup message instead of a generic error.

---

## 5. Branded email (“Nuvelo” not “Supabase”)

Supabase’s built-in mailer always shows as Supabase in Gmail. To look like Instagram/Amazon (sender **Nuvelo**), use **Custom SMTP** and your domain.

### Recommended path

1. Pick a transactional email provider: **Resend**, **SendGrid**, **Postmark**, or **Amazon SES**.
2. Verify domain **`nuvelo.one`** (DNS: SPF, DKIM, optionally DMARC).
3. Create sender e.g. `Nuvelo <no-reply@nuvelo.one>`.

### Supabase

1. **Authentication → Emails → SMTP Settings** → Enable custom SMTP.
2. Host, port, user, password from your provider.
3. **Sender email**: `no-reply@nuvelo.one`
4. **Sender name**: `Nuvelo`

### Email templates

**Authentication → Emails → Templates** — edit subject/body for:

- Confirm signup
- Magic link (if used)
- Reset password
- Change email

Use “Nuvelo” in subjects, e.g. `Reset your Nuvelo password`.

### Note

This cannot be fixed from app code alone; it requires dashboard + DNS + SMTP.

---

## Quick checklist

| Feature | Supabase provider | External setup |
|--------|-------------------|----------------|
| Phone SMS | Phone + Twilio | Twilio account |
| Apple | Apple | Apple Services ID + key |
| Facebook | Facebook | Meta app (in progress) |
| Google | Google | Google OAuth client |
| Branded email | Custom SMTP | Resend/SendGrid + DNS |
