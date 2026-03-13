## InterHungary Marketplace

InterHungary is a cross-platform marketplace for internationals and Hungarians to trade **rentals, jobs, services, and goods** in one trusted place.  
The goal is to make it easy to discover and offer opportunities across language and cultural barriers in Hungary.

---

### Features

- **Multi-category marketplace**: rentals, jobs, services, and goods in one feed.
- **Cross‑platform app**: single Flutter codebase targeting iOS, Android, and Huawei devices.
- **Admin moderation UI**: lightweight dashboard for reviewing listings and users.
- **API backend**: Node.js service exposing REST endpoints for the mobile app and admin UI.
- **MVP-focused**: simple scaffolding with in‑memory / mock data to iterate quickly.

---

### Tech stack

- **Mobile**: Flutter (Dart)
- **Backend**: Node.js (TypeScript/JavaScript)
- **Admin UI**: HTML/CSS/JS (framework‑minimal)
- **Infrastructure**: Render (backend), Codemagic (CI/CD for mobile)

Repository layout:

- `mobile/` – Flutter application (iOS/Android/Huawei)
- `backend/` – Node.js API server
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

#### 2. Admin UI

The admin UI is a static site intended for quick moderation and debugging.

```bash
cd admin-ui
# Option A: open index.html directly in a browser
# Option B: serve it via a simple HTTP server
python3 -m http.server 8080
```

Then open `http://localhost:8080` (or just open `index.html` in your browser if served directly).

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
- Once deployed, note the **public base URL** of the API, for example `https://interhungary-backend.onrender.com`.

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

Some of the directions considered for InterHungary:

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
