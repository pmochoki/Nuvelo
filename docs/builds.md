# Test Builds

Flutter must be installed locally to generate binaries.

## Android (Play Store + Huawei)
1. `cd mobile`
2. `flutter pub get`
3. `flutter build appbundle`
4. Output: `mobile/build/app/outputs/bundle/release/app-release.aab`

Huawei accepts AAB or APK. To generate APK:
- `flutter build apk`

## iOS (App Store / TestFlight)
1. `cd mobile`
2. `flutter pub get`
3. `flutter build ipa`
4. Upload the `.ipa` with Xcode Organizer or Transporter.

## API base URL
- Ensure `useLocalApi = false` in `mobile/lib/api.dart` for Render.
