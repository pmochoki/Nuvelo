# Deployment and Testing

## GitHub
- Initialize git and push to GitHub under the `pmochoki` account.

## Render (backend)
- **Dashboard (this project):** [Render service](https://dashboard.render.com/web/srv-d5q8jh7gi27c73f6jp3g)
1. Create a new Render service from the GitHub repo (or use the link above).
2. Render detects `render.yaml` and deploys the backend automatically.
3. Copy the public service URL from the dashboard (e.g. `https://interhungary-backend.onrender.com`) and set it in the mobile app: **`mobile/lib/api.dart`** → `renderBaseUrl`. The app currently uses `https://interhungary-backend.onrender.com` when `useLocalApi` is `false`. The **public website** is served at the root of that same URL; the **admin moderation UI** is at `/admin/`.

## Vercel (public website)

Use Vercel to host the static marketplace in `web/` while the API stays on Render.

1. Log in at [vercel.com](https://vercel.com) with your Google account (**pmochoki@gmail.com**).
2. **Add New… → Project** → Import **`pmochoki/InterHungary`** from GitHub.
3. **Root Directory:** set to **`web`** (Configure → Root Directory → `web`).
4. Framework preset: **Other** (no build command). Output is the `web` folder as static files.
5. **Environment variables:** none required. The browser calls **`https://interhungary-backend.onrender.com`** automatically when the site is not served from `localhost` or `*.onrender.com` (see `web/app.js`).
6. Deploy. Production URL will look like `https://<project>.vercel.app`; you can add a custom domain under Project → **Domains**.

**Optional:** Install the [Vercel CLI](https://vercel.com/docs/cli), run `cd web && vercel link` to attach the folder to the same project, then `vercel --prod` for deploys from the terminal.

## Testing builds
- iOS: TestFlight via Apple Developer account.
- Android: Internal testing track via Google Play Console.
- Huawei: AppGallery Connect testing channel.

## Store submission prep
- Privacy policy and terms hosted online.
- Store screenshots and app icons ready.
