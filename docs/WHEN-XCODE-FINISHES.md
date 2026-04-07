# When Xcode finishes expanding

Do these in order. The **xcrun: unable to find "xcodebuild"** error will go away after step 2.

---

## 1. Move Xcode to Applications

- In **Finder** → **Downloads** (or wherever the .xip was), find **Xcode.app**.
- **Drag Xcode.app** into **Applications**.
- You can delete **Xcode_14.3.1.xip** to free space.

---

## 2. Point the command line to Xcode

Open **Terminal** and run (you’ll be asked for your Mac password):

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Type your password when asked (nothing will show), then press Enter.

---

## 3. Open Xcode once

- Open **Xcode** from **Applications**.
- **Accept the license** and install any **extra components** it asks for.
- You can quit Xcode after that.

---

## 4. Install CocoaPods (fixes "CocoaPods not installed" error)

Flutter needs CocoaPods to build for **macOS** and **iOS**. In Terminal:

```bash
brew install cocoapods
```

If you see "A brew install cocoapods process has already locked", wait a few minutes (another install may be running) and try again, or close any other Terminal window that might be running `brew install`.

---

## 5. Run the Nuvelo app again

In Terminal:

```bash
cd ~/Nuvelo/mobile
flutter run
```

When Flutter asks which device, choose **1** (macOS) or **2** (Chrome). For **iOS simulator**, open Xcode → Window → Devices and Simulators and start an iPhone simulator first, then run `flutter run` and pick the iOS device.

Pick **iOS** (or macOS) when Flutter asks which device to use.

---

## Optional later: run the backend locally

To run the API on your Mac (for the admin dashboard or local testing):

1. Install Node.js: `brew install node`
2. Start the backend:
   ```bash
   cd ~/Nuvelo/backend
   npm install
   npm run start
   ```
3. Open **admin-ui/index.html** in your browser; it will talk to `http://localhost:4000`.

Right now the mobile app uses the **Render** API; you don’t need the backend running to use the app.
