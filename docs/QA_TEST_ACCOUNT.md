# QA test account (Hungary)

Private account for you (and agents helping you) to feel the **logged-in** experience on [nuvelo.one](https://nuvelo.one). Do not publish these details publicly.

## Recommended test identity

| Field | Suggestion |
|-------|------------|
| **Email** | A Gmail alias only you use, e.g. `you+nuvelo-qa@gmail.com` |
| **Display name** | `Nuvelo QA` |
| **Role** | Seller (so posting ads matches real sellers) |
| **Phone (optional)** | Your Hungarian mobile `+36…` if you want to test SMS login |

## Create the account (no special backend step)

1. Open **https://nuvelo.one** → **Registration**.
2. Enter display name + role + **email only**.
3. Tap **Continue** → Supabase sends a **magic link** to your inbox.
4. Open the link on the same device → you are signed in.

**Note:** Nuvelo web sign-in uses **email magic links**, not a password field. If you created a user in Supabase with a password, use **Sign in** → enter that email → **Continue** → open the magic link (or use Supabase Dashboard → Authentication → Users → send magic link).

Phone SMS is **disabled on the site** until Twilio is configured.

## After sign-in, try

- **Profile** (bottom tab on phone): name, saved ads, settings  
- **Post an ad** (`/post`): category, **gallery photos**, HUF price, Budapest (or your city)  
- **My adverts** in profile: pending until approved in admin  
- **Messages** (when another user contacts you)

## Admin approval

Approve your test ads at **https://nuvelo.one/kingnuvelo** (password: set `VITE_ADMIN_PASSWORD` in Vercel → redeploy).

## SMS in Hungary

Phone OTP is sent by **Supabase Auth** (Twilio or another SMS provider in Supabase Dashboard → Authentication → Phone). Hungary (`+36`) must be enabled. If SMS fails, use **email magic link** for QA.

## Email vs phone verification

- **Email:** magic link (click once — no 6-digit code in the app).  
- **Phone:** 6-digit SMS code in the modal.  
- **Do not fill both** on the same attempt — the app allows one method at a time.
