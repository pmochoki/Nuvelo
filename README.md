# InterHungary Marketplace

Cross-platform marketplace MVP for internationals and Hungarians to trade rentals, jobs, services, and goods.

## Structure
- `mobile/` Flutter app (iOS/Android/Huawei)
- `backend/` Node.js API server
- `admin-ui/` Lightweight moderation dashboard
- `docs/` Product scope, data model, APIs, and release notes

## Quick start (local)
1. Backend: `cd backend && npm install && npm run start`
2. Admin UI: open `admin-ui/index.html`
3. Mobile: `cd mobile && flutter pub get && flutter run`

## Render deployment
- `render.yaml` is ready to deploy the backend.
- After deploy, update the mobile app API base URL to the Render URL.

## Status
MVP scaffolding with in-memory data for API and mock data in the app.
