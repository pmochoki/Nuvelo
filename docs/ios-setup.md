# iOS setup (after installing Xcode)

## One-command setup (recommended)

From the project root, run in **Terminal** (you’ll be asked for your Mac password once):

```bash
cd "/Users/mokoro/Library/Mobile Documents/com~apple~CloudDocs/InterHungary /InterHungary-src"
bash scripts/ios-setup-and-run.sh
```

The script will: install Homebrew (if needed) → install Flutter → point Xcode command-line tools to Xcode → run `flutter doctor` → run the InterHungary app. When it asks for your password, type it and press Enter.

---

## Manual steps (if you prefer)

### 1. Finish Xcode one-time setup

1. **Open Xcode** once from Applications (or Spotlight: `Cmd+Space` → "Xcode").
2. **Accept the license** if prompted.
3. **Install extra components** if Xcode asks (e.g. "Install additional required components").
4. **Point command-line tools to Xcode** (needed for Flutter / simulators):
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
   Enter your Mac password when asked.

## 2. Install Flutter (if not already)

- **Option A – Homebrew (easiest):**
  ```bash
  brew install --cask flutter
  ```
- **Option B – Manual:** [flutter.dev/docs/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)

Then confirm:
```bash
flutter doctor
```
Fix any issues it reports (e.g. "Accept Xcode license", "Install CocoaPods").

## 3. Run the InterHungary app on iOS

From the project root:

```bash
cd mobile
flutter pub get
flutter run
```

- If you have **multiple devices** (simulator + physical iPhone), choose **iOS** when Flutter asks.
- First run may take a few minutes (building, downloading simulator if needed).

## 4. Optional: open in Xcode

To run or archive from Xcode:

```bash
cd mobile
open ios/Runner.xcworkspace
```

Then in Xcode: pick a simulator or your iPhone and press Run (▶).

## Quick checks

| Check | Command |
|-------|--------|
| Xcode path | `xcode-select -p` → should be `/Applications/Xcode.app/Contents/Developer` |
| Xcode version | `xcodebuild -version` |
| Flutter | `flutter --version` |
| Flutter iOS | `flutter doctor` (look for ✓ for iOS / Xcode) |
