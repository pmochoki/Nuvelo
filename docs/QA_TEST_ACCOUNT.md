# QA test account (Hungary)

Private account for you (and agents helping you) to feel the **logged-in** experience on [nuvelo.one](https://nuvelo.one). Do not publish these details publicly.

## Recommended test identity

| Field | Suggestion |
|-------|------------|
| **Email** | A Gmail alias only you use, e.g. `you+nuvelo-qa@gmail.com` |
| **Password** | At least 8 characters (store in your password manager) |
| **Display name** | `Nuvelo QA` |
| **Role** | Seller (so posting ads matches real sellers) |

## Create the account

1. Open **https://nuvelo.one** → **Registration**.
2. Enter display name, role, **email**, and **password**.
3. Tap **Create account** — you are signed in (unless Supabase requires email confirmation).

## Sign in again

1. **Sign in** → **Continue with Google** / **Facebook**, or enter **email + password** → **Sign in**.

Phone SMS is **not shown** on the site until Twilio is configured in Supabase.

## After sign-in, try

- **Profile** (bottom tab on phone): name, saved ads, settings  
- **Post an ad** (`/post`): category, **gallery photos**, HUF price, Budapest (or your city)  
- **My adverts** in profile: pending until approved in admin  
- **Messages** (when another user contacts you)

## Admin approval

Approve your test ads at **https://nuvelo.one/kingnuvelo** (password: set `VITE_ADMIN_PASSWORD` in Vercel → redeploy).

## Supabase checklist

- **Authentication → Providers → Email:** enable email + password.  
- For the simplest QA flow, turn off **Confirm email** (or confirm via inbox before signing in).  
- **Google / Facebook:** configured under Authentication → Providers if you test OAuth.
