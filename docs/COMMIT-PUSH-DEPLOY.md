# Commit, push, and how to see the app

## What’s already done

- **Committed** in your local repo: Jiji-style UI, 5-tab nav, orange theme, iOS docs, setup script.  
- **Not done from here:** push (needs your GitHub login) and any deploy steps.

---

## 1. Push to GitHub (you do this once)

Open **Terminal** and run:

```bash
cd "/Users/mokoro/Library/Mobile Documents/com~apple~CloudDocs/InterHungary /InterHungary-src"
git push origin main
```

- If it asks for **username**: your GitHub username (e.g. `phoeni8x`).
- If it asks for **password**: use a **Personal Access Token**, not your GitHub password.  
  Create one: GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token**. Give it `repo` scope, copy it, and paste it when Git asks for password.

Alternatively, use **SSH** so you don’t type a password every time:

```bash
# Check if you have a key
ls -la ~/.ssh/id_*.pub

# If not, create one (then add the .pub to GitHub → Settings → SSH keys)
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519 -N ""

# Use SSH remote instead of HTTPS
git remote set-url origin git@github.com:phoeni8x/InterHungary.git
git push origin main
```

After a successful push, your latest commit will be on:  
**https://github.com/phoeni8x/InterHungary**

---

## 2. Deploy (what gets updated where)

| Part        | How it deploys | Where you see it |
|------------|----------------|-------------------|
| **Backend** | If the repo is connected to **Render**, Render usually auto-deploys on push to `main`. Check [Render dashboard](https://dashboard.render.com/web/srv-d5q8jh7gi27c73f6jp3g). | API: `https://interhungary-backend.onrender.com` (or your Render URL). |
| **Mobile app** | No automatic web deploy in this repo. You can: (1) run locally, (2) use **Codemagic** (see `codemagic.yaml`) to build iOS/Android, (3) build and upload to App Store / Play Store yourself. | See “How to see the app” below. |
| **Admin UI** | Static HTML; not deployed by this repo. You can host `admin-ui/` on any static host (e.g. GitHub Pages, Netlify) or open `admin-ui/index.html` locally. | Locally: open `admin-ui/index.html` in a browser. |

So: **push = code on GitHub**. Backend “deploy” = Render (if connected). Mobile “deploy” = you run the app or use Codemagic/App Store/Play Store.

---

## 3. How to see the app

### Option A: In the browser (no Xcode needed)

```bash
cd "/Users/mokoro/Library/Mobile Documents/com~apple~CloudDocs/InterHungary /InterHungary-src/mobile"
flutter run -d chrome
```

Chrome will open with the InterHungary app (Jiji-style UI). This is the **customer app** in the browser.

### Option B: On iOS simulator (after Xcode is set up)

```bash
cd "/Users/mokoro/Library/Mobile Documents/com~apple~CloudDocs/InterHungary /InterHungary-src/mobile"
flutter run
```

Choose **iOS** when Flutter asks. Or run the setup script once (see `docs/WHEN-XCODE-FINISHES.md`), then run the app.

### Option C: On a physical iPhone

Connect the phone, enable Developer Mode, then:

```bash
cd ".../InterHungary-src/mobile"
flutter run
```

Select your iPhone from the device list.

### Option D: Backend only (API)

- If Render is connected and has auto-deployed: open  
  `https://interhungary-backend.onrender.com/health`  
  (or your Render service URL) in a browser to confirm the API is up.
- The mobile app (Chrome or device) already points at this backend when not using local API.

---

## Quick reference

| Goal              | Command / action |
|-------------------|------------------|
| Push latest code  | `git push origin main` (in Terminal, in `InterHungary-src`) |
| See app in browser | `cd .../InterHungary-src/mobile && flutter run -d chrome` |
| See backend       | Open Render service URL (e.g. `.../health`) or use the app (it calls the API) |
| Deploy backend    | Rely on Render auto-deploy on push, or trigger a deploy from the Render dashboard |
