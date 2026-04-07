# Deployment and Testing

## GitHub
- Initialize git and push to GitHub under the `pmochoki` account.

## Render (backend)
- **Dashboard (this project):** [Render service](https://dashboard.render.com/web/srv-d5q8jh7gi27c73f6jp3g)
1. Create a new Render service from the GitHub repo (or use the link above).
2. Render detects `render.yaml` and deploys the backend automatically.
3. Copy the public service URL from the dashboard (e.g. `https://interhungary-backend.onrender.com`) and set it in the mobile app: **`mobile/lib/api.dart`** → `renderBaseUrl`. The app currently uses `https://interhungary-backend.onrender.com` when `useLocalApi` is `false`. The **public website** is served at the root of that same URL; the **admin moderation UI** is at `/admin/`.

## Testing builds
- iOS: TestFlight via Apple Developer account.
- Android: Internal testing track via Google Play Console.
- Huawei: AppGallery Connect testing channel.

## Store submission prep
- Privacy policy and terms hosted online.
- Store screenshots and app icons ready.
