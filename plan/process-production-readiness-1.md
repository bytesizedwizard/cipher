---
goal: Close all production-readiness gaps in Cipher
version: 1.0
date_created: 2026-09-26
last_updated: 2026-09-26
owner: bytesizedwizard
status: 'In progress'
tags: [process, security, release, flutter, mobile, hotp, biometric, bug]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

This plan converts the production-readiness audit into executable work. It preserves the verified account-persistence implementation while closing lifecycle-authentication, sensitive-data privacy, HOTP, identifier safety, dependency, signing, CI, documentation, and device-validation gaps.

Implementation status: code, documentation, host validation, Android debug
builds, unsigned iOS Release builds, and the iOS simulator account integration
suite are complete. Credentialed Android/iOS release signing, physical-device
lifecycle/privacy checks, Android integration execution, and remote GitHub
Actions execution remain external gates.

## 1. Requirements & Constraints

- **REQ-001**: Preserve the authoritative account record format in `FlutterSecureStorage` and preserve successful QR/manual account persistence across provider recreation and application restart.
- **REQ-002**: Do not publish OTP values while the application is locked, inactive, paused, or awaiting biometric authentication.
- **REQ-003**: Require successful biometric authentication on every resume when `Settings.biometricAuthEnabled` is `true`; never silently bypass authentication because hardware is unavailable, authentication fails, or the device is locked out.
- **REQ-004**: Keep account metadata available for locked-state rendering only when the metadata contains no secret or current OTP value.
- **REQ-005**: Implement RFC 4226 HOTP generation, counter persistence, and explicit counter advancement, or do not accept HOTP imports. This plan selects full HOTP implementation because the parser, model, README, and product description already advertise HOTP.
- **REQ-006**: Use collision-safe identifiers for all in-memory maps, routes, account lookup, and deletion. Legacy raw `issuer:label` keys may remain only as migration inputs.
- **REQ-007**: Clear copied OTP values after the configured timeout and clear them immediately when the application locks or backgrounds.
- **REQ-008**: Protect Android task-switcher/background snapshots with `FLAG_SECURE` and mask iOS application content before background snapshots.
- **REQ-009**: Keep secrets in platform secure storage. Do not add plaintext files, logs, analytics events, network requests, or debug output containing secrets.
- **REQ-010**: Release builds must use compatible dependency, Gradle, Android signing, iOS signing, provisioning, and entitlement configuration.
- **REQ-011**: Release validation must prove `get-task-allow = false` on iOS archives and verify Android APK signatures without exposing signing credentials.
- **REQ-012**: CI must run code generation consistency, static analysis, the complete test suite, dependency checks, secret scanning, and release-build validation.
- **REQ-013**: Android and iOS are supported production targets. Web must not be advertised as equivalent secure-storage support unless its threat model is explicitly implemented and tested.
- **REQ-014**: Documentation must describe only implemented behavior. Claims about authenticated encryption, HOTP, backup/restore, reorder/edit, and web security must match code.
- **SEC-001**: No biometric failure path may navigate to `/home` or expose account-detail screens when biometric protection is enabled.
- **SEC-002**: OTP state must be replaced with redacted values before platform background snapshots can capture the application.
- **SEC-003**: Clipboard cleanup must use a generation/token guard so an older delayed callback cannot erase a newer copied value.
- **SEC-004**: Storage and UI errors must exclude secret material, Base32 values, encoded secrets, and full storage payloads.
- **SEC-005**: CI signing values, keystore files, provisioning profiles, and certificates must be supplied through protected CI secrets or local ignored files; none may be committed.
- **CON-001**: Follow feature-based structure under `lib/src/feature/` and existing Riverpod, Freezed, GoRouter, Flutter Secure Storage, and test conventions.
- **CON-002**: Run `dart run build_runner build --delete-conflicting-outputs` after changing any `@freezed`, `@JsonSerializable`, or `@Riverpod` declaration.
- **CON-003**: Do not use `--android-skip-build-dependency-validation` to hide an incompatible Android toolchain.
- **CON-004**: Do not commit unrelated feature plans `plan/feature-account-sort-1.md` and `plan/feature-auto-service-logos-1.md`.
- **CON-005**: Commit only reviewed platform migration edits; never commit signing credentials, provisioning profiles, keystores, or generated build outputs.
- **GUD-001**: Prefer shared services and existing helpers over duplicate clipboard, authentication, storage, or identifier logic.
- **GUD-002**: Preserve the last valid account metadata state when refresh fails, but never preserve visible OTP values after a lock/background transition.
- **GUD-003**: Make every failure visible through a typed state or user-facing error; do not use broad catches that create success-shaped fallbacks.
- **PAT-001**: Use `AsyncNotifier` for asynchronous account state and keep all account mutations serialized through `AuthController`.
- **PAT-002**: Use `AccountStorageService` as the only account-secret persistence boundary.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Normalize the worktree and restore a green, reproducible Flutter/Dart toolchain before feature changes.
- GATE-001: `analysis_options.yaml` contains no unexplained analyzer exclusion; generated platform migration edits are either reverted or represented by Phase 5 tasks; dependency resolution completes without a beta `flutter_secure_storage` constraint; `dart analyze` and all host tests pass.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Retain the Flutter-generated target-directory analyzer exclusions in `analysis_options.yaml` because they cover native/build paths outside Dart analysis; verify the documented Dart source remains analyzable and `dart analyze` passes with no issues. | ✅ | 2026-09-26 |
| TASK-002 | Review and deliberately retain the Android/iOS migration edits required by the normalized Swift Package Manager, UIScene, privacy-overlay, and release-signing configuration. Do not alter the three persistence commits `6791015`, `37bea3e`, or `64841e8`. | ✅ | 2026-09-26 |
| TASK-003 | Use stable `flutter_secure_storage: ^10.3.4` and compatible `material_symbols_icons: ^4.2960.0`; resolve dependencies and regenerate code without beta storage packages. | ✅ | 2026-09-26 |
| TASK-004 | Run `dart pub outdated --no-dev-dependencies` and `dart pub upgrade`; retain major versions that require a separate compatibility review and record the resulting lockfile state. | ✅ | 2026-09-26 |
| TASK-005 | Use Gradle `8.14.0`, AGP `8.11.1`, and KGP `2.2.20`; verify `flutter analyze --suggestions` reports a compatible Java/Gradle/AGP/KGP set without using `--android-skip-build-dependency-validation`. | ✅ | 2026-09-26 |
| TASK-006 | Run code generation, `dart analyze`, `flutter test`, formatting, whitespace checks, and generated-file reproducibility checks. | ✅ | 2026-09-26 |

### Implementation Phase 2

- GOAL-002: Add explicit locked/unlocked application-session state and enforce biometric reauthentication across lifecycle resumes.
- GATE-002: With biometric protection enabled, pause/inactive clears visible OTPs, resume keeps the app locked until authentication succeeds, failed authentication cannot navigate to `/home`, and successful authentication restores account views and restarts the ticker.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-007 | Create the keep-alive `AppLockController` with explicit locked/authenticating/unlocked state, settings-driven biometric behavior, coalesced authentication, and no secret/OTP storage. | ✅ | 2026-09-26 |
| TASK-008 | Make lifecycle lock transitions cancel refreshes, clear OTP-bearing views, and invalidate stale asynchronous refresh generations. | ✅ | 2026-09-26 |
| TASK-009 | Serialize authenticated resume hydration, refresh account views, publish state, and restart the ticker only after successful unlock. | ✅ | 2026-09-26 |
| TASK-010 | Route splash authentication through the shared app-lock controller and keep failed authentication on the authentication-required state. | ✅ | 2026-09-26 |
| TASK-011 | Add lock-aware GoRouter redirects for protected routes and back-stack restoration. | ✅ | 2026-09-26 |
| TASK-012 | Render locked/authentication-required account surfaces without exposing stale OTPs. | ✅ | 2026-09-26 |
| TASK-013 | Add host tests for authentication coalescing/failure/success, lifecycle locking, OTP redaction, and protected-route redirects. | ✅ | 2026-09-26 |

### Implementation Phase 3

- GOAL-003: Protect sensitive content in platform snapshots and centralize secure clipboard behavior.
- GATE-003: Android screenshots/task switcher show no OTP content, iOS background snapshots show a non-sensitive mask, both OTP copy surfaces honor timeout, and lock/background clears clipboard state without stale timer races.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-014 | Set `WindowManager.LayoutParams.FLAG_SECURE` before Android Flutter content is rendered; retain device verification as an external gate. | ✅ | 2026-09-26 |
| TASK-015 | Configure Flutter's UIScene manifest and use the AppDelegate privacy overlay for will-resign-active/did-become-active transitions; retain plugin registration and SPM integration. Physical snapshot verification remains an external gate. | ✅ | 2026-09-26 |
| TASK-016 | Implement the injectable, tokenized `SecureClipboardService` provider with one active cleanup timer and explicit clear behavior. | ✅ | 2026-09-26 |
| TASK-017 | Route home/detail copy actions and app-lock cleanup through the shared secure clipboard service. | ✅ | 2026-09-26 |
| TASK-018 | Add fake-writer/timer tests for timeout cleanup, replacement-copy isolation, explicit clear, zero timeout, and lock-triggered cleanup. | ✅ | 2026-09-26 |

### Implementation Phase 4

- GOAL-004: Complete HOTP support and remove collision-prone account identifiers while preserving legacy migration.
- GATE-004: RFC 4226 vectors pass, HOTP imports require and preserve a counter, HOTP codes advance only through an explicit serialized action, TOTP behavior remains unchanged, and accounts whose issuer/label contain colons remain isolated in lookup and deletion.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-019 | Use collision-safe authoritative IDs for `Account.id`/`storageId`, retain `legacyId` for migration and deletion compatibility, and isolate legacy-key handling. | ✅ | 2026-09-26 |
| TASK-020 | Update account maps, routes, lookup, and deletion to use canonical IDs consistently; regenerate affected files. | ✅ | 2026-09-26 |
| TASK-021 | Require HOTP counters, persist them in version-2 records, and migrate version-1 records with counter defaults. | ✅ | 2026-09-26 |
| TASK-022 | Implement RFC 4226 HOTP generation with Base32 decoding, big-endian counters, SHA1/SHA256/SHA512 HMAC selection, dynamic truncation, and zero padding. | ✅ | 2026-09-26 |
| TASK-023 | Make refresh type-specific: TOTP remains time-based and HOTP remains stable at its persisted counter. | ✅ | 2026-09-26 |
| TASK-024 | Persist HOTP counter advancement through verified storage writes and serialized `AuthController` operations. | ✅ | 2026-09-26 |
| TASK-025 | Add explicit HOTP “Next code” behavior without TOTP countdown semantics or copy-triggered advancement. | ✅ | 2026-09-26 |
| TASK-026 | Add RFC 4226, migration, counter, refresh-stability, and colon-collision tests while preserving RFC 6238 coverage. | ✅ | 2026-09-26 |

### Implementation Phase 5

- GOAL-005: Make Android and iOS release configuration reproducible, signed, and privacy-safe.
- GATE-005: A release build completes on Android and iOS with external signing inputs, Android signature verification passes, iOS archive entitlements have `get-task-allow = false`, and no signing credential is tracked.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-027 | Fail closed when Android release signing inputs are absent; consume local ignored or CI-generated signing configuration and retain release shrinking/minification. | ✅ | 2026-09-26 |
| TASK-028 | Keep only camera/biometric permissions in the Android manifest, omit `INTERNET`, and add CI assertions for the offline manifest/signing-material contract. | ✅ | 2026-09-26 |
| TASK-029 | Configure iOS Release for Apple Distribution/manual CI signing without personal profiles, certificates, or private keys in the repository. | ✅ | 2026-09-26 |
| TASK-030 | Normalize iOS Release xcconfig, entitlements, bundle identifier, Swift Package integration, and UIScene configuration; unsigned Release build passes locally. Credentialed archive validation remains external. | ✅ | 2026-09-26 |
| TASK-031 | Add Android/iOS signed-artifact verification commands to the release workflow. Credentialed signing and `apksigner`/`codesign` execution remain pending external CI credentials. | ⚠️ | 2026-09-26 |

### Implementation Phase 6

- GOAL-006: Establish automated quality, dependency, security, and release gates.
- GATE-006: Pull requests fail on analyzer errors, generated-code drift, test failures, dependency/toolchain incompatibility, leaked secrets, or release-artifact verification failures.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-032 | Run pinned Flutter setup, dependency installation, code generation, generated-file drift checks, formatting, analysis, tests, dependency reporting, whitespace checks, and Android/iOS build jobs in `.github/workflows/ci.yml`. | ✅ | 2026-09-26 |
| TASK-033 | Add OSV dependency scanning, gitleaks secret scanning, and a narrow deterministic test-fixture allowlist without committing signing material. | ✅ | 2026-09-26 |
| TASK-034 | Build `.github/workflows/release.yml` with a release quality gate, protected Android/iOS signing inputs, artifact verification, cleanup, and artifact uploads. Remote credentialed execution remains external. | ✅ | 2026-09-26 |
| TASK-035 | Enforce unresolved-marker checks for the production plan/generated Dart files and require a clean worktree after code generation in CI. | ✅ | 2026-09-26 |
| TASK-036 | Guard unsupported web/desktop startup targets and document Android/iOS-only production support. | ✅ | 2026-09-26 |

### Implementation Phase 7

- GOAL-007: Reconcile documentation and complete platform-level production validation.
- GATE-007: Documentation matches implemented behavior, the persistence plan has accurate completion markers, and the device matrix passes on both Android and iOS release builds.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-037 | Reconcile README, changelog, and contributor instructions with platform secure storage, implemented HOTP, absent backup/edit/reorder features, and Android/iOS-only production support. | ✅ | 2026-09-26 |
| TASK-038 | Update the persistence plan only with evidence-backed status; retain explicit migration and device-validation limitations. | ⚠️ | 2026-09-26 |
| TASK-039 | Extend `integration_test/account_persistence_test.dart` with real-storage QR decoding, service recreation, HOTP counter persistence, and colon-collision deletion isolation. Process death, biometric, snapshot, and clipboard checks remain manual/device gates. | ✅ | 2026-09-26 |
| TASK-040 | Execute the integration suite on Android and iOS, including process termination and task switching, and record device evidence. iOS simulator storage tests pass; Android and lifecycle/snapshot execution remain pending. | | |
| TASK-041 | Perform manual release acceptance checks for lifecycle, biometric, snapshot, clipboard, QR/manual creation, restart, HOTP, deletion, and log/privacy behavior. | | |
| TASK-042 | Run the final clean-checkout and credentialed release verification sequence; mark this plan `Completed` only after TASK-040 and TASK-041 have evidence. | | |

## 3. Alternatives

- **ALT-001**: Reject all `otpauth://hotp/...` URIs immediately. Not chosen because HOTP is advertised in `README.md`, model constants, URI parsing, and product description; full RFC 4226 support is the deterministic completion path.
- **ALT-002**: Keep raw `${issuer}:${label}` as `Account.id` and rely on encoded storage keys only. Not chosen because UI/state lookup and deletion still collide before storage access.
- **ALT-003**: Keep biometric authentication only in `SplashScreen`. Not chosen because lifecycle resume can expose OTPs after the initial splash gate.
- **ALT-004**: Hide build failures with `--android-skip-build-dependency-validation` or by excluding more paths from analysis. Not chosen because this masks incompatible production tooling.
- **ALT-005**: Add a custom AES-GCM layer immediately over platform secure storage. Not chosen for this plan because the current implementation has no key-management contract for an additional layer; documentation will describe platform secure storage accurately until a separately specified encryption design exists.
- **ALT-006**: Clear the clipboard using independent delayed callbacks. Not chosen because an older callback can erase a newer copied code; tokenized cleanup is required.

## 4. Dependencies

- **DEP-001**: Flutter SDK and Dart SDK versions declared by the repository environment.
- **DEP-002**: Stable `flutter_secure_storage`, Flutter-compatible `material_symbols_icons`, Riverpod, Freezed, `local_auth`, and `mobile_scanner` package versions resolved through `pubspec.lock`.
- **DEP-003**: Gradle `8.14.0` or newer compatible with the selected Android Gradle Plugin and Kotlin toolchain.
- **DEP-004**: Android keystore values supplied through ignored local configuration or protected CI secrets.
- **DEP-005**: Apple Distribution certificate, provisioning profile, development team, and App Store/archive credentials supplied outside the repository.
- **DEP-006**: Android and iOS physical devices or equivalent emulators/simulators capable of biometric, lifecycle, screenshot, secure-storage, and clipboard validation.
- **DEP-007**: `build_runner`, Freezed, JSON serialization, and Riverpod code generation completing without generated-code drift.
- **DEP-008**: GitHub Actions runners with Flutter, Android SDK, Xcode, `apksigner`, `codesign`, and the approved dependency/secret scanners.

## 5. Files

- **FILE-001**: `lib/src/providers/app_lock_provider.dart` — new locked/unlocked session controller.
- **FILE-002**: `lib/src/feature/account/providers/auth_providers.dart` — lifecycle lock, OTP redaction, authenticated resume, HOTP counter advancement, and serialized state operations.
- **FILE-003**: `lib/src/feature/account/models/auth_models.dart` and generated files — collision-safe IDs and optional HOTP counter.
- **FILE-004**: `lib/src/feature/account/utils/account_storage_keys.dart` — authoritative ID and legacy-ID separation.
- **FILE-005**: `lib/src/feature/account/services/account_storage_service.dart` — counter persistence, version migration, legacy identifier handling, and verified writes.
- **FILE-006**: `lib/src/feature/account/services/totp_service.dart` — RFC 4226 HOTP generation and type-specific refresh.
- **FILE-007**: `lib/src/feature/account/screens/add_account_screen.dart`, `view_account_screen.dart`, and `lib/src/feature/home/screens/home_screen.dart` — lock rendering, HOTP controls, and secure clipboard usage.
- **FILE-008**: `lib/src/feature/account/widgets/delete_account_dialog.dart` and `lib/src/routes.dart` — collision-safe deletion and locked-route protection.
- **FILE-009**: `lib/src/ui/services/secure_clipboard_service.dart` — new tokenized clipboard service and provider.
- **FILE-010**: `ios/Runner/SceneDelegate.swift`, `ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist`, `ios/Runner.xcodeproj/project.pbxproj`, `ios/Flutter/Release.xcconfig`, and `ios/Runner/Runner.entitlements` — iOS snapshot masking and distribution signing.
- **FILE-011**: `android/app/src/main/kotlin/dev/bytesizedwizard/cipherauth/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle.kts`, and `android/gradle/wrapper/gradle-wrapper.properties` — Android privacy, manifest, signing, and toolchain configuration.
- **FILE-012**: `pubspec.yaml` and `pubspec.lock` — compatible stable dependencies.
- **FILE-013**: `lib/main.dart` — supported-platform guard.
- **FILE-014**: `README.md` and `plan/data-account-persistence-1.md` — accurate product/security documentation and persistence-plan status.
- **FILE-015**: `.github/workflows/ci.yml` and `.github/workflows/release.yml` — automated quality and signed-release gates.
- **FILE-016**: `test/feature/account/`, new lock/clipboard/HOTP tests, `test/widget_test.dart`, and `integration_test/account_persistence_test.dart` — host and device regression coverage.

## 6. Testing

- **TEST-001**: Run `dart analyze` with the analyzer exclusion removed; require zero errors and zero warnings introduced by the plan.
- **TEST-002**: Run `flutter test`; require all widget, service, provider, migration, identifier, clipboard, lifecycle, and OTP tests to pass.
- **TEST-003**: Run `dart run build_runner build --delete-conflicting-outputs` followed by `git diff --exit-code`; require generated files to be reproducible.
- **TEST-004**: Verify RFC 6238 SHA1/SHA256/SHA512 vectors and existing TOTP rollover behavior.
- **TEST-005**: Verify RFC 4226 SHA1 vectors for counters 0 through 9 plus SHA256/SHA512 implementation coverage.
- **TEST-006**: Verify URI parsing rejects invalid scheme/type/algorithm/digits/period/secret and rejects HOTP counter values that are missing, negative, or non-integer.
- **TEST-007**: Verify authoritative secure-record round trip, read-back verification failure cleanup, malformed-record isolation, legacy migration idempotence, version-1-to-version-2 migration, missing-secret preservation, and deletion isolation.
- **TEST-008**: Verify issuer/label colon collision cases produce distinct IDs, distinct routes, independent lookup, and independent deletion.
- **TEST-009**: Verify app lock clears OTP values, blocks protected routes, clears clipboard, handles authentication failure/lockout, and restores OTPs only after successful authentication.
- **TEST-010**: Verify clipboard timeout, replacement-copy token isolation, zero timeout, detail/home parity, and lock-triggered cleanup with a fake clipboard adapter.
- **TEST-011**: Verify Android `FLAG_SECURE` and iOS snapshot overlay on supported device/simulator configurations.
- **TEST-012**: Verify Android release artifact signature with `apksigner verify --verbose` and iOS archive signature/entitlements with `codesign`.
- **TEST-013**: Verify release builds contain no debug-only permissions, no signing files, no secret logs, and no `get-task-allow` entitlement.
- **TEST-014**: Run Android and iOS integration tests after cold start, process termination, background/resume, task switching, QR import, migration, and account deletion.
- **TEST-015**: Run CI from a clean checkout and require codegen consistency, analyzer success, full tests, dependency scan, secret scan, signed artifact verification, and clean worktree.

## 7. Risks & Assumptions

- **RISK-001**: HOTP counter semantics may differ from user expectations. The plan removes ambiguity by advancing only through an explicit “Next code” action and never on passive refresh or copy.
- **RISK-002**: Biometric APIs and lifecycle callback ordering differ between Android and iOS. Device tests must verify both inactive/paused transitions and process termination rather than relying only on host tests.
- **RISK-003**: iOS scene lifecycle migration may conflict with the existing Flutter/Xcode project. Keep one configured scene delegate path, verify plugin registration, and fail the iOS archive gate if the generated project is inconsistent.
- **RISK-004**: Dependency upgrades may require API changes. Apply the minimum stable versions needed for toolchain compatibility first, then update affected adapters and regenerate code.
- **RISK-005**: Release signing cannot be fully validated without external Apple and Android credentials. CI must fail closed when credentials are absent; local unsigned builds do not satisfy the release gate.
- **RISK-006**: Existing version-1 account records may omit HOTP counters. Treat missing counters as valid only for TOTP records; reject HOTP records without a counter and preserve them for explicit migration/error handling.
- **RISK-007**: Web secure storage may not provide mobile-equivalent hardware-backed guarantees. Keep web outside the supported production target until a separate threat-model and implementation review is complete.
- **ASSUMPTION-001**: `FlutterSecureStorage` is the authoritative mobile at-rest boundary; platform keychain/keystore configuration is trusted and no plaintext backup is introduced.
- **ASSUMPTION-002**: Cipher remains offline-first and does not require `INTERNET` permission in the production Android manifest.
- **ASSUMPTION-003**: Existing persistence commits `6791015`, `37bea3e`, and `64841e8` are the baseline for all remaining work.
- **ASSUMPTION-004**: No user-requested behavior requires account sync, cloud backup, account editing, or app-level authenticated encryption in this production-hardening cycle.

## 8. Related Specifications / Further Reading

- [RFC 4226: HOTP: An HMAC-Based One-Time Password Algorithm](https://www.rfc-editor.org/rfc/rfc4226)
- [RFC 6238: TOTP: Time-Based One-Time Password Algorithm](https://www.rfc-editor.org/rfc/rfc6238)
- [Flutter app lifecycle documentation](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)
- [Android `FLAG_SECURE` documentation](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)
- [Apple scene lifecycle documentation](https://developer.apple.com/documentation/uikit/app_and_environment/managing_your_app_s_life_cycle)
- [Flutter secure storage package](https://pub.dev/packages/flutter_secure_storage)
- [Flutter integration testing documentation](https://docs.flutter.dev/testing/integration-tests)
- [GitHub Actions documentation](https://docs.github.com/en/actions)
