# Deployment and Testing

## GitHub
- Initialize git and push to GitHub under the `pmochoki` account.

## Render (backend)
- **Dashboard (this project):** [Render service](https://dashboard.render.com/web/srv-d5q8jh7gi27c73f6jp3g)
1. Create a new Render service from the GitHub repo (or use the link above).
2. Render detects `render.yaml` and deploys the backend automatically.
3. Copy the public service URL from the dashboard (e.g. `https://nuvelo-backend.onrender.com`) and set it in the mobile app: **`mobile/lib/api.dart`** → `renderBaseUrl`. The app currently uses `https://nuvelo-backend.onrender.com` when `useLocalApi` is `false`. The **public website** is served at the root of that same URL; the **admin moderation UI** is at `/admin/`.

## Vercel (public website + `/api` serverless routes)

The repo has a **root** [`vercel.json`](../vercel.json) that builds the Vite app under `web/`, publishes **`web/dist`** as static output, and exposes **Node serverless handlers** from the repo-root [`api/`](../api/) directory (for example `/api/health`, `/api/listings`).

**Why `/api/*` returned `NOT_FOUND`:** The Vercel project **Root Directory** is set to **`web`** (confirmed via `vercel project inspect nuvelo`). Serverless handlers must live in **`web/api/`** (synced from repo-root `api/` on each build). If you change Root Directory to the repository root instead, you could use top-level `api/` only — current setup keeps `web` as root.

### Correct Vercel project settings

1. Log in at [vercel.com](https://vercel.com) with your Google account (**pmochoki@gmail.com**).
2. Open the **nuvelo** project → **Settings** → **General**.
3. **Root Directory:** should be **`web`** (current production setting). In the dashboard UI: **Settings → General → scroll to "Root Directory"** (sometimes under "Build & Development Settings"). Click **Edit** if you need to change it.
4. **Build & Output Settings** (for `web` root):
   - **Install Command:** `npm install` (runs in `web/`; `prebuild` syncs `api/`)
   - **Build Command:** `npm run build`
   - **Output Directory:** `dist`
5. Framework preset: **Other** (root `vercel.json` sets `"framework": null`).
6. **Environment variables:** set any required by [`api/`](../api/) (for example backend URL if used by proxies—see `api/_backend.js`). The SPA may still call Render for data depending on `web/app.js` → `API_BASE`.
7. **Save**, then **Deployments** → **Redeploy** the latest production deployment (or push to `main`).

**CLI (optional):** Link and deploy from the **repository root** so the same root `vercel.json` applies:

```bash
cd /path/to/Nuvelo
vercel link    # project root, not web/
vercel --prod
```

Do **not** use `cd web && vercel link` for this setup; that attaches the project to the `web/` subdirectory and omits `api/`.

### Verify production

After deploy, these should return **HTTP 200** and JSON (not Vercel `NOT_FOUND`):

```bash
curl -sS -o /dev/null -w "%{http_code}\n" https://nuvelo.one/api/health
curl -sS https://nuvelo.one/api/health
curl -sS -o /dev/null -w "%{http_code}\n" https://nuvelo.one/api/listings
curl -sS https://nuvelo.one/api/listings | head -c 500
```

### Production redeploy checklist

- [ ] **Root Directory** is repository root (empty), not `web`.
- [ ] Build commands match root `vercel.json` (`install` / `build` under `web`, **Output Directory** `web/dist`).
- [ ] Required env vars for `api/` are set in **Project → Settings → Environment Variables** (Production).
- [ ] Trigger a new deployment after changing Root Directory or env vars.
- [ ] Re-run the `curl` checks above on the production domain.

## Testing builds
- iOS: TestFlight via Apple Developer account.
- Android: Internal testing track via Google Play Console.
- Huawei: AppGallery Connect testing channel.

## Store submission prep
- Privacy policy and terms hosted online.
- Store screenshots and app icons ready.
