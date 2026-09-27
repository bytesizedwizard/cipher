# Cipher

Cipher is an offline-first Flutter authenticator for iOS and Android. It
generates TOTP (RFC 6238) and HOTP (RFC 4226) codes and keeps account
secrets on the device.

## Features

- Add TOTP or HOTP accounts by scanning an `otpauth://` QR code or entering
  account details manually.
- Generate SHA-1, SHA-256, and SHA-512 codes with configurable digit lengths.
- Advance HOTP counters explicitly with **Next code**; passive refreshes never
  consume a counter.
- Store account records and secrets in platform secure storage
  (Android Keystore or iOS Keychain).
- Lock the account view behind biometric authentication when enabled.
- Protect background snapshots and clear copied codes after the configured
  clipboard timeout.
- Search, sort, inspect, copy, and delete accounts.
- Persist theme, biometric, and clipboard settings locally.

Cipher does not currently provide cloud sync, backup/restore, account editing,
or account reordering. The web target is not a supported production target
because browser storage does not provide the same security properties as
mobile secure storage.

## Supported standards

- TOTP (RFC 6238)
- HOTP (RFC 4226)
- `otpauth://` URI format
- QR codes containing `otpauth://` URIs

## Storage and security model

Account records are stored in platform secure storage under versioned,
collision-safe keys. Secrets are serialized as Base64 inside those records;
Base64 is an encoding, not an encryption layer. The security boundary is the
platform secure-storage implementation and the device's access controls.

When biometric protection is enabled, Cipher locks on backgrounding, redacts
OTP state, clears the managed clipboard value, and requires successful
reauthentication before returning to the account view. Android uses
`FLAG_SECURE`, and iOS masks the application window while inactive.

No telemetry or user-identifying data is sent off-device by default. Users
remain responsible for protecting the device and retaining any service
recovery codes.

## Tech stack

- Flutter `3.47.2`, Dart `3.13.2`
- Riverpod and Freezed code generation
- `go_router`
- `flutter_secure_storage`
- `local_auth`

## Project structure

```text
/lib                         Flutter application source
/lib/src/feature/account     Account parsing, storage, and OTP generation
/lib/src/feature/home        Account list and code display
/lib/src/feature/settings    Theme, biometric, and clipboard settings
/lib/src/feature/splash      Startup and authentication gate
/lib/src/providers           Shared providers, lock, palette, and clipboard
/test                        Unit and widget tests
/integration_test            Device-level persistence tests
/android                     Android platform integration
/ios                         iOS platform integration
/.github/workflows           CI and signed artifact workflows
/plan                        Implementation plans and acceptance criteria
```

## Development

Install the pinned Flutter toolchain, then run:

```bash
flutter pub get
dart run build_runner build
dart analyze
flutter test
flutter run
```

After changing `@freezed` or `@Riverpod` declarations, regenerate the
generated files with `dart run build_runner build`.

## Release artifacts

`.github/workflows/ci.yml` runs formatting, code generation, analysis, tests,
Android debug builds, unsigned iOS release builds, dependency scanning, and
secret scanning.

`.github/workflows/release.yml` runs for `v*` tags or manual dispatch. It
requires repository or environment secrets for the Android upload keystore and
Apple Distribution certificate/provisioning profile. It builds and verifies
signed Android `.aab`/`.apk` files and a signed iOS `.ipa`, then uploads them
as GitHub Actions artifacts. The workflow does not publish to Google Play or
the App Store.

Required signing secret names:

- Android: `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`,
  `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`
- iOS: `APPLE_CERTIFICATE_BASE64`, `APPLE_CERTIFICATE_PASSWORD`,
  `APPLE_KEYCHAIN_PASSWORD`, `APPLE_PROVISIONING_PROFILE_BASE64`,
  `APPLE_TEAM_ID`

Never commit keystores, certificates, provisioning profiles, passwords, or
`android/key.properties`.
