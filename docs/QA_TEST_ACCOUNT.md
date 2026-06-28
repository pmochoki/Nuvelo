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
2. Enter display name + role.
3. Use **email only** (leave phone empty) for the simplest path:
   - Tap **Continue** → Supabase sends a **magic link** to your inbox.
   - Open the link on the same phone or laptop → you are signed in.
4. Or use **phone only** (leave email empty):
   - Enter `+36…` → **Continue** → enter the **SMS code** → **Verify code**.

There is no separate “test user” table — it is a normal Supabase Auth user. Keep the email/phone private.

## After sign-in, try

- **Profile** (bottom tab on phone): name, saved ads, settings  
- **Post an ad** (`/post`): category, **gallery photos**, HUF price, Budapest (or your city)  
- **My adverts** in profile: pending until approved in admin  
- **Messages** (when another user contacts you)

## Admin approval

Approve your test ads at **https://nuvelo.one/kingnuvelo** (password in Vercel `VITE_ADMIN_PASSWORD` or default team password).

## SMS in Hungary

Phone OTP is sent by **Supabase Auth** (Twilio or another SMS provider in Supabase Dashboard → Authentication → Phone). Hungary (`+36`) must be enabled. If SMS fails, use **email magic link** for QA.

## Email vs phone verification

- **Email:** magic link (click once — no 6-digit code in the app).  
- **Phone:** 6-digit SMS code in the modal.  
- **Do not fill both** on the same attempt — the app allows one method at a time.
