---
goal: Make QR-added accounts durable across application restarts
version: 1.0
date_created: 2026-08-06
last_updated: 2026-08-06
owner: bytesizedwizard
status: In progress
tags: [bug, critical, persistence, security, account]
---

# Introduction

![Status: In progress](https://img.shields.io/badge/status-In%20progress-yellow)

Fix account loss after application close/reopen by replacing the split account
metadata/secret persistence path with one authoritative secure-storage record,
migrating existing accounts, verifying successful writes, and making cold-start
loading awaitable and error-aware. The fix must preserve existing accounts and
must not expose secrets in logs, exceptions, tests, or user-facing messages.

Implementation status: application changes and automated host tests are complete.
The real-platform integration test is included but requires Android or iOS
execution outside the current environment.

## 1. Requirements & Constraints

- **REQ-001**: A successfully added QR or manually entered account must be readable from a new storage-service instance after the add operation completes.
- **REQ-002**: New account records must use one authoritative secure-storage record containing the account metadata and encoded secret together.
- **REQ-003**: Existing accounts stored as SharedPreferences metadata plus a separate secure-storage secret must be migrated without data loss.
- **REQ-004**: Account writes must be verified by reading and decoding the newly written record before the add operation reports success.
- **REQ-005**: If a write, verification, migration, or delete operation fails, the error must be propagated as a typed persistence error and the UI must not claim success.
- **REQ-006**: Cold-start account loading must await migration and OTP hydration before exposing the loaded account state.
- **REQ-007**: One malformed or incomplete account record must not silently replace all valid accounts with an empty state.
- **REQ-008**: Existing account search, sorting, QR parsing, OTP generation, deletion, clipboard behavior, and routes must remain compatible.
- **SEC-001**: Authentication secrets must remain exclusively in FlutterSecureStorage; SharedPreferences must continue to contain settings only.
- **SEC-002**: Do not log, serialize into errors, or display raw secrets, encoded secrets, QR payloads, or secure-storage values.
- **CON-001**: Use the existing FlutterSecureStorage, Riverpod, Freezed, and JSON serialization dependencies; do not introduce a database or network dependency for this fix.
- **CON-002**: Preserve the existing legacy key format `${issuer}:${label}` for migration and compatibility.
- **CON-003**: Preserve the current `StorageService` abstraction for low-level secure-storage and SharedPreferences access.
- **PAT-001**: Continue using feature-based organization under `lib/src/feature/account/`.
- **PAT-002**: Continue using `@freezed` and `@Riverpod`; regenerate generated files after annotated source changes.
- **PAT-003**: Use canonical account identifiers consistently for map keys, routes, deletion, and persisted record keys.

## 2. Implementation Steps

### Implementation Phase 1

- GOAL-001: Define the authoritative secure account record and canonical key contract.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Create `lib/src/feature/account/models/stored_account.dart` with a `@freezed` `StoredAccountRecord` model containing `Account account`, `String encodedSecret`, and `int version`; add JSON serialization and set the initial record version to `1`. Persist `account.otp` as `null` because OTP is transient UI state. | | |
| TASK-002 | Create `lib/src/feature/account/utils/account_storage_keys.dart` with constants and helpers: legacy metadata key `${issuer}:${label}`, legacy secret key `${legacyKey}_secret`, authoritative record prefix `account:`, and collision-safe authoritative record key `account:${Uri.encodeComponent(issuer)}:${Uri.encodeComponent(label)}`. All helpers must accept the issuer and label separately and return deterministic strings. | | |
| TASK-003 | Update `lib/src/feature/account/models/auth_models.dart` so `Account.id` returns the canonical legacy identifier `${issuer}:${label}` rather than only `label`; add a `storageId` getter that delegates to the key helper. Update generated model files through code generation. | | |
| TASK-004 | Add an `AccountStorageIssue` typed error model in `lib/src/feature/account/models/errors.dart` for invalid record, missing secret, verification failure, and migration failure cases. Error messages must contain only the safe account identifier and operation name, never secret material. | | |
| DONE-001 | A stored account record round-trips through JSON, every account has one canonical identifier, and the new record key cannot collide for issuers or labels containing reserved URI characters. | | |

### Implementation Phase 2

- GOAL-002: Implement authoritative secure persistence, verification, migration, and deletion.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Create `lib/src/feature/account/services/account_storage_service.dart` with a Riverpod keep-alive provider and methods `save(Account account, String secret)`, `loadAll()`, `readSecret(Account account)`, `delete(Account account)`, and `migrateLegacyAccounts()`. Inject a small storage-backend interface so the service can be tested with an in-memory implementation without platform plugins. | | |
| TASK-006 | Implement `save()` to validate the Base32 secret, encode it with `base64Encode(utf8.encode(secret))`, write exactly one `StoredAccountRecord` to the authoritative secure-storage key, read the record back, decode it, and compare the canonical identifier and encoded-secret length/content. Throw `AccountStorageIssue` and delete the new record if verification fails. | | |
| TASK-007 | Implement `loadAll()` to call secure-storage `readAll()`, filter only keys beginning with `account:`, parse each record independently, validate record version, validate the account fields, and return valid records plus typed issues. Do not parse settings or unrelated secure-storage keys as accounts. | | |
| TASK-008 | Implement `readSecret()` to load the authoritative record by canonical key, decode the stored Base64 value, reject missing/empty/corrupt values with `AccountStorageIssue`, and provide a legacy-key fallback only for records that have not completed migration. | | |
| TASK-009 | Implement `migrateLegacyAccounts()` to enumerate SharedPreferences entries excluding `SettingsConstants.storageKey`, parse each legacy `Account`, read its legacy secure-storage secret, create and verify the authoritative record, then delete the old metadata and old secret only after verification succeeds. Keep legacy entries intact and report a typed issue when migration cannot complete. | | |
| TASK-010 | Implement `delete()` to delete the authoritative record and then remove matching legacy metadata and legacy secret keys. Treat a missing key as success, but propagate actual storage failures. | | |
| TASK-011 | Refactor `lib/src/feature/account/services/auth_service.dart` to delegate account add, load, and delete operations to `AccountStorageService`; retain query filtering over loaded account metadata and remove direct account writes to SharedPreferences. | | |
| TASK-012 | Refactor `lib/src/feature/account/services/totp_service.dart` so `refresh(Account account)` reads the secret through `AccountStorageService.readSecret()` and no longer reconstructs storage keys independently. Remove or delegate the unused label-only `delete(Account)` implementation. | | |
| DONE-002 | New accounts are represented by one verified secure record, legacy accounts are migrated idempotently, and no new account metadata is written to SharedPreferences. | | |

### Implementation Phase 3

- GOAL-003: Make account state loading serialized, awaitable, and resilient to partial records.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | Refactor `lib/src/feature/account/providers/auth_providers.dart` so `AuthController` is an `AsyncNotifier` exposing `AsyncValue<Map<String, AccountView>>`. Set `AsyncData` only after migration, account loading, and the first complete OTP refresh succeed, and set `AsyncError` with a sanitized error for failures. | | |
| TASK-014 | Refactor `AuthController.build()` to await `migrateLegacyAccounts()`, await account loading, await the first OTP refresh, and start the periodic timer only after successful initialization. Do not use fire-and-forget calls for initialization or refresh operations. | | |
| TASK-015 | Add an in-flight refresh guard or generation token to `_tick()` so periodic ticks cannot overwrite newer account data with stale results. Preserve the last valid `AsyncData` state when a later refresh fails, while surfacing the sanitized error state to the UI. | | |
| TASK-016 | Refactor `refreshAccounts(String query)`, `addAccount()`, `addAccountFromUri()`, and `deleteAccount()` to await persistence, refresh, and state publication in order. An operation must return only after the new state is available or a typed error is thrown. | | |
| TASK-017 | Update `lib/src/feature/home/screens/home_screen.dart` to consume `AsyncValue`, render loading and safe error states, and use `valueOrNull` only for explicitly empty-state logic. Do not interpret an initialization error as “Nothing to see here!”. | | |
| TASK-018 | Update `lib/src/feature/account/screens/view_account_screen.dart` to consume `AsyncValue`, handle a missing account without `firstWhere` failure, and use `item.account.id` for deletion rather than reconstructing a separate key. | | |
| TASK-019 | Update `lib/src/feature/account/widgets/delete_account_dialog.dart` and all account route callers to pass the canonical `Account.id`; ensure deletion uses the same identifier used by persistence and `AuthController`. | | |
| DONE-003 | A cold start cannot display an empty account list while initialization is still running or failed, and all add/delete/refresh operations have deterministic completion semantics. | | |

### Implementation Phase 4

- GOAL-004: Close the QR/manual UI lifecycle race and preserve user-visible error behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-020 | Update `lib/src/feature/account/screens/add_account_screen.dart` QR `onDetect` handling so it awaits `addAccountFromUri()` and the resulting state refresh before navigating to `/home`; keep the duplicate-scan guard and reset it on every handled failure. | | |
| TASK-021 | Update the manual-entry submit callback in `add_account_screen.dart` to be `async`, await `addAccount(account, secret)`, navigate only after success, and keep the screen open while showing a sanitized persistence error on failure. | | |
| TASK-022 | Add a safe persistence-failure dialog or snackbar path using `AccountStorageIssue`; do not reuse “Invalid code format” for storage failures because that incorrectly attributes a persistence failure to QR parsing. | | |
| TASK-023 | Ensure app lifecycle resume in `AuthController.didChangeAppLifecycleState` awaits a full account reload or refresh before restarting the ticker, without clearing a valid state on transient failure. | | |
| DONE-004 | QR and manual additions cannot navigate away before verified persistence, and storage failures are distinguishable from invalid QR payloads. | | |

### Implementation Phase 5

- GOAL-005: Add regression coverage for persistence, restart hydration, migration, and failure handling.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-024 | Create `test/feature/account/services/account_storage_service_test.dart` with an in-memory backend covering authoritative record round-trip, Base32 validation, write verification failure, idempotent migration, missing legacy secret, malformed record isolation, and deletion of both new and legacy keys. | | |
| TASK-025 | Create `test/feature/account/services/auth_service_test.dart` covering QR-style URI-derived accounts, query filtering after reload, canonical identifiers, and the guarantee that successful `addAccount()` can be loaded by a new service instance. | | |
| TASK-026 | Create `test/feature/account/services/totp_service_test.dart` with RFC 6238 vectors using the new `AccountStorageService.readSecret()` path and a missing/corrupt-record failure case. | | |
| TASK-027 | Create `test/feature/account/providers/auth_providers_test.dart` covering initial load, awaited first refresh, serialized refreshes, preservation of valid state after a later refresh failure, and provider recreation against the same backend. | | |
| TASK-028 | Replace the obsolete counter-template contents of `test/widget_test.dart` with a provider-overridden `CipherApp` bootstrap test that verifies loading/error/empty account states do not crash and that a persisted account appears after provider recreation. | | |
| TASK-029 | Add `integration_test/account_persistence_test.dart` or an equivalent device-level test using the real platform storage plugins. Add an account through the controller, force a lifecycle stop/resume or application recreation, and verify the account remains available without asserting or printing secret values. | | |
| TASK-030 | Run `dart run build_runner build --delete-conflicting-outputs`, `dart analyze`, and `flutter test`; run the device-level persistence test on Android and iOS where platform storage behavior differs. | | |
| DONE-005 | Automated coverage proves that an account added through the QR/controller path survives service/provider recreation, legacy data migrates, and failures are visible without secret leakage. | | |

## 3. Alternatives

- **ALT-001**: Keep account metadata in SharedPreferences and only add a delayed flush or arbitrary sleep after QR scanning. Rejected because timing does not provide an atomic or verifiable persistence guarantee.
- **ALT-002**: Continue using two independent stores and add retry logic only on startup. Rejected because retries do not repair partial writes and can still leave metadata and secret records inconsistent.
- **ALT-003**: Introduce SQLite/Drift/SQLCipher for account records. Rejected for this fix because it adds a new storage dependency and migration surface; the existing secure-storage dependency can provide an authoritative record without introducing a database.
- **ALT-004**: Store only the secret in secure storage and retain metadata in SharedPreferences. Rejected because the account index would remain vulnerable to the same persistence and cold-start failure mode.

## 4. Dependencies

- **DEP-001**: Existing `flutter_secure_storage` package for authoritative account records and secrets.
- **DEP-002**: Existing `shared_preferences` package for settings and legacy-account migration input only.
- **DEP-003**: Existing `freezed`, `freezed_annotation`, `json_serializable`, and `build_runner` packages for the stored-record model and generated code.
- **DEP-004**: Existing Riverpod generated providers and `ProviderScope` overrides for isolated persistence tests.
- **DEP-005**: Flutter SDK `flutter_test` and `integration_test` support for regression coverage.

## 5. Files

- **FILE-001**: `lib/src/feature/account/models/stored_account.dart` - New versioned authoritative record model.
- **FILE-002**: `lib/src/feature/account/models/stored_account.freezed.dart` - Generated Freezed implementation.
- **FILE-003**: `lib/src/feature/account/models/stored_account.g.dart` - Generated JSON serialization.
- **FILE-004**: `lib/src/feature/account/models/auth_models.dart` - Canonical account identifier behavior.
- **FILE-005**: `lib/src/feature/account/models/errors.dart` - Typed persistence and migration issues.
- **FILE-006**: `lib/src/feature/account/utils/account_storage_keys.dart` - Canonical and legacy key helpers.
- **FILE-007**: `lib/src/feature/account/services/account_storage_service.dart` - Authoritative record storage, verification, migration, and deletion.
- **FILE-008**: `lib/src/feature/account/services/account_storage_service.g.dart` - Generated provider implementation.
- **FILE-009**: `lib/src/feature/account/services/auth_service.dart` - Account repository delegation and query filtering.
- **FILE-010**: `lib/src/feature/account/services/totp_service.dart` - Secret lookup through the authoritative storage service.
- **FILE-011**: `lib/src/feature/account/providers/auth_providers.dart` - Awaited, error-aware, serialized account state.
- **FILE-012**: `lib/src/feature/account/providers/auth_providers.g.dart` - Generated provider type changes.
- **FILE-013**: `lib/src/feature/account/screens/add_account_screen.dart` - Awaited QR/manual persistence and distinct storage errors.
- **FILE-014**: `lib/src/feature/account/screens/view_account_screen.dart` - Async account state and canonical deletion ID.
- **FILE-015**: `lib/src/feature/account/widgets/delete_account_dialog.dart` - Canonical account deletion input.
- **FILE-016**: `lib/src/feature/home/screens/home_screen.dart` - Async loading/error/empty-state rendering.
- **FILE-017**: `test/feature/account/services/account_storage_service_test.dart` - Storage, verification, migration, and deletion tests.
- **FILE-018**: `test/feature/account/services/auth_service_test.dart` - Account add/reload/query tests.
- **FILE-019**: `test/feature/account/services/totp_service_test.dart` - OTP regression and secret lookup tests.
- **FILE-020**: `test/feature/account/providers/auth_providers_test.dart` - Restart hydration and refresh serialization tests.
- **FILE-021**: `test/widget_test.dart` - Replace obsolete counter-template test.
- **FILE-022**: `integration_test/account_persistence_test.dart` - Real-device lifecycle persistence test.
- **FILE-023**: `README.md` or `.github/copilot-instructions.md` - Document the authoritative account-record contract and migration behavior.

## 6. Testing

- **TEST-001**: `StoredAccountRecord` JSON round-trip preserves account metadata, version, and encoded secret without persisting transient OTP state.
- **TEST-002**: `AccountStorageService.save()` writes one authoritative secure record and succeeds only when a verified read-back matches.
- **TEST-003**: A new `AccountStorageService` instance loads an account saved by a previous instance using the same backend.
- **TEST-004**: Legacy SharedPreferences metadata plus legacy secure secret migrate exactly once and are removed only after authoritative verification.
- **TEST-005**: Legacy records with missing secrets remain recoverable and produce a typed issue without deleting metadata.
- **TEST-006**: Malformed or unrelated secure-storage entries do not hide valid accounts or cause an empty successful state.
- **TEST-007**: QR URI account addition persists before navigation and remains available after provider recreation.
- **TEST-008**: Manual account addition awaits persistence and keeps the screen open on persistence failure.
- **TEST-009**: AuthController waits for the first refresh, prevents overlapping ticks, and preserves valid state after a later refresh failure.
- **TEST-010**: Account deletion removes the authoritative record and legacy keys using the same canonical identifier.
- **TEST-011**: RFC 6238 TOTP vectors still pass after secret lookup is routed through `AccountStorageService`.
- **TEST-012**: Device-level Android and iOS lifecycle tests verify account availability after application recreation without logging secrets.

## 7. Risks & Assumptions

- **RISK-001**: Existing installations may contain metadata without a matching secure secret. Mitigation: retain the legacy metadata, report a typed issue, and never delete it during failed migration.
- **RISK-002**: Secure-storage `readAll()` may contain unrelated application keys. Mitigation: filter exclusively by the `account:` record prefix.
- **RISK-003**: Changing `Account.id` from label-only to issuer-plus-label may affect persisted UI route extras. Mitigation: update all route callers and use the canonical ID consistently; no route should rely on label-only IDs.
- **RISK-004**: A secure-storage write can still be interrupted by an abrupt operating-system kill. Mitigation: use one authoritative record, verify read-back before success, and add device-level lifecycle coverage; do not claim durability based only on an arbitrary delay.
- **RISK-005**: Loading every account record from secure storage can be slower for large account sets. Mitigation: keep record parsing bounded to account-prefixed keys and measure startup behavior during device testing.
- **ASSUMPTION-001**: Existing legacy account metadata keys use the format `${issuer}:${label}` and legacy secrets use `${issuer}:${label}_secret`.
- **ASSUMPTION-002**: FlutterSecureStorage is available on all supported production platforms and can enumerate account-prefixed records through `readAll()`.
- **ASSUMPTION-003**: Settings remain stored under `SettingsConstants.storageKey` in SharedPreferences and are outside the account migration.
- **ASSUMPTION-004**: No account secret is intentionally stored in SharedPreferences by released versions of the application.

## 8. Related Specifications / Further Reading

- `lib/src/feature/account/services/auth_service.dart`
- `lib/src/feature/account/services/storage_service.dart`
- `lib/src/feature/account/services/totp_service.dart`
- `lib/src/feature/account/providers/auth_providers.dart`
- `lib/src/feature/account/screens/add_account_screen.dart`
- `lib/src/feature/settings/utils/constants.dart`
- `README.md`
- `CHANGELOG.md`
- https://pub.dev/packages/flutter_secure_storage
- https://pub.dev/packages/shared_preferences
