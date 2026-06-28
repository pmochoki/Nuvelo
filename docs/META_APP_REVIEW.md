# Meta App Review — Nuvelo Facebook Login

Use this when submitting **App Review** for permissions `email` and `public_profile` on Meta app **Nuvelo** (`4426473634349036`).

## Pre-flight checklist (verified)

| Item | Status |
|------|--------|
| Production site | `https://nuvelo.one` |
| Privacy policy | `https://nuvelo.one/privacy` (200) |
| Terms | `https://nuvelo.one/terms` (200) |
| Supabase Site URL | `https://nuvelo.one` |
| Supabase redirect URLs | `https://nuvelo.one/**`, `one.nuvelo.app://login-callback` |
| Supabase providers | Email, Google, Apple, **Facebook** enabled |
| Meta OAuth redirect URI | `https://ahiujuljjbozmfwoqtli.supabase.co/auth/v1/callback` |
| Meta app domains | `nuvelo.one`, `ahiujuljjbozmfwoqtli.supabase.co` |
| Meta **Website → Site URL** | `https://nuvelo.one` (required for reviewer instructions) |
| Permissions requested | `email`, `public_profile` |

## Sign-in / sign-up on Nuvelo (for reviewers)

Nuvelo is a classifieds marketplace (Hungary). Users can:

1. **Register** — header → **Registration** → display name, role, email, password → **Create account**
2. **Sign in** — header → **Sign in** → **Continue with Google / Apple / Facebook**, or email + password
3. **Forgot password** — Sign in → **Forgot password?** → email → reset link → `/reset-password`

Facebook Login flow:

1. Open `https://nuvelo.one`
2. Click **Sign in**
3. Click **Continue with Facebook**
4. Approve **email** and **public profile**
5. User returns to nuvelo.one signed in

We use Facebook data **only** to authenticate the user and pre-fill name/email on first sign-in. We do not post to Facebook or access friends/lists.

## Reviewer instructions (paste into Meta)

```
App URL: https://nuvelo.one

How to test Facebook Login:
1. Open https://nuvelo.one in a desktop browser (Chrome recommended).
2. Click "Sign in" in the top navigation.
3. Click "Continue with Facebook".
4. Log in with a personal Facebook account that has a confirmed email (not a business/Page-only profile).
5. Approve the requested permissions (email and public profile).
6. You will be redirected back to nuvelo.one and signed in.

How to test email + password registration (no Facebook required):
1. Click "Registration" in the header.
2. Enter display name, role, email, and password.
3. Click "Create account".

Privacy policy: https://nuvelo.one/privacy
Terms: https://nuvelo.one/terms
Data deletion: https://nuvelo.one/privacy (contact section)

Test note: App admins testing from a Facebook business/Page profile (e.g. "Nuvelo Entreprises") may not receive email from Meta; use a standard personal Facebook account for login testing.
```

## Allowed usage (typical answers)

**email** — We request the user's email to create and secure their Nuvelo account and to send transactional messages (password reset, listing notifications). We do not sell email addresses.

**public_profile** — We use name and profile picture to display the seller/buyer identity on listings and in messages.

## Submit steps in Meta Developer Portal

1. **App Review → Submissions** → permissions `email` + `public_profile` → **Next**
2. **Verification** — complete **Business verification** if Meta requires it (documents for Nuvelo / Paul, Hungary)
3. **App settings** — confirm icon, display name, privacy URL
4. **Allowed usage** — answer how each permission is used (see above)
5. **Data handling** — confirm encryption, retention, deletion via privacy policy
6. **Reviewer instructions** — paste the block above; add a short screen recording if Meta asks
7. **Submit for review**
8. After approval → **Publish** → switch app **Live**

## After approval

- Any Facebook user with a personal account can use **Continue with Facebook**
- You can add real listings and onboard sellers without tester-role limits

## While waiting for review

Use **Google**, **Apple**, or **email + password** for your own account and QA (`docs/QA_TEST_ACCOUNT.md`). Add personal Facebook as **App roles → Tester** to test Facebook before Live.
