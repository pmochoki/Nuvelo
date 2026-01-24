# Codemagic iOS Setup

## 1) Add secrets in Codemagic
Create a group named `appstore_credentials` and add:
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY` (contents of the `.p8` file)

## 2) Code signing
In Codemagic UI, enable automatic code signing and select your Apple Developer team.

## 3) Build
Run the `iOS Release` workflow.

Artifacts:
- IPA: `mobile/build/ios/ipa/*.ipa`
