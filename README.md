## Nuvelo Marketplace

Nuvelo is a cross-platform marketplace for internationals and Hungarians to trade **rentals, jobs, services, and goods** in one trusted place.  
The goal is to make it easy to discover and offer opportunities across language and cultural barriers in Hungary.

---

### Features

- **Multi-category marketplace**: rentals, jobs, services, and goods in one feed.
- **Cross‑platform app**: single Flutter codebase targeting iOS, Android, and Huawei devices.
- **Public website**: browse and post listings in the browser (same API as the app).
- **Admin moderation UI**: lightweight dashboard for reviewing listings and users (`/admin` on the backend host).
- **API backend**: Node.js service exposing REST endpoints for the mobile app and admin UI.
- **MVP-focused**: simple scaffolding with in‑memory / mock data to iterate quickly.

---

### Tech stack

- **Mobile**: Flutter (Dart)
- **Backend**: Node.js (TypeScript/JavaScript)
- **Public web**: HTML/CSS/JS (`web/`, served at `/` by the backend)
- **Admin UI**: HTML/CSS/JS (framework‑minimal, served at `/admin`)
- **Infrastructure**: Render (backend), Codemagic (CI/CD for mobile)

Repository layout:

- `mobile/` – Flutter application (iOS/Android/Huawei)
- `backend/` – Node.js API server
- `web/` – Public marketplace site (browse, sign-in, post listings)
- `admin-ui/` – Browser-based moderation dashboard
- `docs/` – Product scope, data model, API contracts, release notes
- `assets/` – Design assets, icons, logos
- `scripts/` – Automation, helper scripts
- `render.yaml` – Render deployment config for the backend
- `codemagic.yaml` – Codemagic pipeline for the mobile app

---

### Getting started (local development)

#### 1. Backend API

```bash
cd backend
npm install
npm run start
```

- The server will start on the port defined in the backend config (check `.env` or config files).
- This MVP currently uses **in‑memory data**, so no external database is required to get started.

#### 2. Public website & admin UI

With the backend running, the same process serves:

- **Marketplace (public):** `http://localhost:4000/` — browse listings, sign in, post new ones.
- **Moderation (admin):** `http://localhost:4000/admin/` — review pending listings and reports.

Opening `admin-ui/index.html` directly without the API will not work for moderation; use the URLs above so requests go to the same origin as the API.

#### 3. Mobile app

Requirements:

- Flutter SDK (see [Flutter install docs](https://docs.flutter.dev/get-started/install))
- Xcode (for iOS) and/or Android Studio (for Android)
- Device/emulator set up and available via `flutter devices`

Run:

```bash
cd mobile
flutter pub get
flutter run
```

Make sure the mobile app’s API base URL matches your running backend (for example `http://10.0.2.2:3000` for Android emulator, or the machine IP for iOS simulator).

---

### Deployment

#### Backend on Render

- The `render.yaml` file contains the configuration to deploy the backend to Render.
- Once deployed, note the **public base URL** of the API, for example `https://nuvelo-backend.onrender.com`.
- **Health check:** open `https://<your-service>.onrender.com/health` — you should see `{"status":"ok"}`. The service is **Node/Express** (not Django); routes include `/categories`, `/listings`, `/auth/login`, `/admin/` (static admin UI).
- **If every path returns plain `Not Found` and response headers include `x-render-routing: no-server`:** Render has no running web process for that hostname (service deleted, never created, or suspended). Fix this in the [Render dashboard](https://dashboard.render.com): create or resume a **Web Service** with **Root directory** `backend`, **Build** `npm install`, **Start** `npm run start`, and health check path `/health`.
- Optional: set env var `CORS_ORIGINS` to a comma-separated list (e.g. `https://nuvelo.one,https://my-app.vercel.app`) to restrict CORS; if unset, the API reflects the request origin (`origin: true`).

#### Configure mobile app for production

In the Flutter project:

- Update the **API base URL** to point to the Render deployment URL.
- Rebuild the app for the desired platforms:

```bash
cd mobile
flutter build apk        # Android
flutter build ios        # iOS (requires macOS + Xcode)
```

---

### Project status

This is an **MVP**:

- Core structure for mobile, backend, and admin UI is in place.
- API currently uses **in‑memory data** / mock data to accelerate iteration.
- Expect breaking changes while the data model and flows are refined.

If you’re interested in using or contributing, please treat this as **early-stage** software.

---

### Roadmap ideas

Some of the directions considered for Nuvelo:

- User authentication & profiles (multi-language support).
- Search and filtering across categories (rentals, jobs, services, goods).
- Messaging between buyers and sellers.
- Basic trust & safety: moderation tools, reporting, and verified users.
- Persistent storage (database) and production-ready deployment story.

---

### Contributing

Contributions and feedback are welcome.

1. Fork the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feature/my-change
   ```
3. Make your changes in the relevant package (`mobile/`, `backend/`, `admin-ui/`).
4. Run local checks (Flutter analyzer, `npm test`, etc., where applicable).
5. Open a pull request with:
   - A short description of the change.
   - Any steps to reproduce or test.

---

### License

This project is currently private and experimental. No explicit open-source license has been added yet; please contact the maintainer before using it in production or redistributing.
