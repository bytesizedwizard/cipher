# Cipher — Copilot Instructions

Security-focused 2FA Flutter app. TOTP (RFC 6238) + HOTP (RFC 4226).

## Build / test / lint

- `flutter pub get` — deps
- `flutter test` — tests
- `dart analyze` — lint
- `dart run build_runner build --delete-conflicting-outputs` — codegen (after @freezed/@Riverpod changes)
- `flutter run` — run

## Architecture

Feature-based under `lib/src/feature/<name>/`. Each has: `models/`, `providers/`, `services/`, `screens/`, `widgets/`, `utils/`.

| Feature | Job | Key files |
|---------|-----|-----------|
| `account` | CRUD, TOTP/HOTP generation, secure persistence | `totp_service.dart`, `auth_service.dart`, `account_storage_service.dart` |
| `home` | TOTP list + countdown | `home_screen.dart` |
| `settings` | Theme, biometric, clipboard timeout | `settings_provider.dart`, `settings_models.dart` |
| `splash` | Boot + biometric gate | `splash_screen.dart` |

Global: `lib/src/providers/` (ColorPalette, platform), `lib/src/ui/` (reusable widgets), `lib/src/routes.dart` (GoRouter).

### Data flow

```
Input → TotpService.decode() → (Account, secret)
  → AuthService.addAccount()
    → FlutterSecureStorage (versioned account record + base64 secret)
  → AuthController.addAccount() → refresh state

AuthController._startTicker() [1s]:
  → TotpService.refresh(account)
    → AccountStorageService.readSecret()
    → decodeBase32Secret()
    → HMAC → dynamic truncation → AccountView to UI
```

### Routes (GoRouter)

| Path | Screen | Note |
|------|--------|------|
| `/splash` | SplashScreen | Biometric gate |
| `/home` | HomeScreen | No transition |
| `/howto` | HowToScreen | Tutorial |
| `/auth/add` | AddEntityScreen | QR/manual |
| `/auth/view` | ViewAccountScreen | `?id = canonical account id` |
| `/settings` | SettingsScreen | No transition |
| `/settings/update` | UpdateSettingScreen | `state.extra = SettingsOption` |

## Conventions (security-critical)

- **Never log/print secrets.** Plain text forbidden.
- Account records and secrets → FlutterSecureStorage through
  `AccountStorageService`.
- SharedPreferences stores settings only; legacy split records migrate on startup.
- Authoritative account key: `"account:${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(label)}"`.
- Delete removes authoritative and legacy records.
- Use `StorageSource` enum (`secureStorage`/`sharedPreferences`).

### State

- Riverpod with `@Riverpod(keepAlive: true)` for services/controllers.
- @freezed for data models.
- `SettingsState` sealed union: `initial/loading/loaded(Settings)/error(String)`.
- `AuthController` holds `Map<String, AccountView>`, redacts OTPs while
  locked, and refreshes TOTP/HOTP views on a 1s ticker.
- `WidgetsBindingObserver` for lifecycle (pause timer on app bg).

### URI parsing

- `TotpService.decode()` handles `otpauth://totp/...` and `otpauth://hotp/...`.
- Validate: scheme=`otpauth`, algorithm∈{SHA1,SHA256,SHA512}, digits/period>0.
- Throw `ParseException` (from `errors.dart`) on invalid input.

### Errors

- `ParseException`, `FetchException` with `ErrorCode` enum.
- UI via `SettingsState.error()` and dialogs.
- `BiometricAuthStatus` enum for biometric results.

### Codegen

After @freezed model or @Riverpod provider changes:
`dart run build_runner build --delete-conflicting-outputs`
Generates `.freezed.dart`, `.g.dart`.

### Theme

- `ColorPalette` interface → `LightPalette` / `DarkPalette`.
- Raw ARGB hex values (not Material ColorScheme).
- Two fonts: **Bytesized** (logo) + **Inter** (UI, 9 weights + italics).
