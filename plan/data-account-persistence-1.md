---
goal: Make QR-added accounts durable across application restarts
version: 1.0
date_created: 2026-08-06
last_updated: 2026-09-26
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

Implementation status: application changes, automated host tests, and the
iOS-simulator real-storage integration suite are complete. Android execution,
process-death validation, and physical lifecycle testing remain external gates.

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
| TASK-001 | Create the versioned `StoredAccountRecord` Freezed/JSON model containing account metadata, Base64-encoded secret, and record version; omit transient OTP state. | ✅ | 2026-09-26 |
| TASK-002 | Create deterministic legacy and collision-safe authoritative storage-key helpers using encoded issuer/label components. | ✅ | 2026-09-26 |
| TASK-003 | Make `Account.id` and `storageId` use the collision-safe authoritative key while retaining `legacyId` for migration compatibility; regenerate model files. | ✅ | 2026-09-26 |
| TASK-004 | Add sanitized typed `AccountStorageIssue` errors for invalid records, missing secrets, verification failures, and migration failures. | ✅ | 2026-09-26 |
| DONE-001 | Stored records round-trip, transient OTP state is omitted, and reserved issuer/label characters cannot collide in authoritative keys. | ✅ | 2026-09-26 |

### Implementation Phase 2

- GOAL-002: Implement authoritative secure persistence, verification, migration, and deletion.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-005 | Implement `AccountStorageService` with an injectable backend and authoritative save/load/read/delete/migration operations. | ✅ | 2026-09-26 |
| TASK-006 | Validate Base32 secrets, write one versioned secure record, read it back, compare safe identity/encoded-secret data, and clean up failed writes. | ✅ | 2026-09-26 |
| TASK-007 | Enumerate only `account:` secure keys, parse records independently, migrate older versions, and return valid records with typed issues. | ✅ | 2026-09-26 |
| TASK-008 | Read authoritative Base64 secrets with a legacy fallback for incomplete migrations and sanitized failure reporting. | ✅ | 2026-09-26 |
| TASK-009 | Migrate legacy SharedPreferences metadata plus secure secrets only after verified authoritative writes; retain failed legacy data. | ✅ | 2026-09-26 |
| TASK-010 | Delete authoritative and legacy records consistently, treating missing keys as success and propagating real storage failures. | ✅ | 2026-09-26 |
| TASK-011 | Delegate account persistence/query/deletion to `AccountStorageService` and remove new account metadata writes to SharedPreferences. | ✅ | 2026-09-26 |
| TASK-012 | Route OTP secret reads through `AccountStorageService.readSecret()` and remove independent storage-key reconstruction. | ✅ | 2026-09-26 |
| DONE-002 | New accounts use one verified secure record, legacy records migrate idempotently, and settings remain the only SharedPreferences data. | ✅ | 2026-09-26 |

### Implementation Phase 3

- GOAL-003: Make account state loading serialized, awaitable, and resilient to partial records.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-013 | Use `AsyncNotifier` account state with sanitized errors and deterministic loaded/locked behavior. | ✅ | 2026-09-26 |
| TASK-014 | Await migration, account loading, initial refresh, and ticker startup; remove initialization fire-and-forget behavior. | ✅ | 2026-09-26 |
| TASK-015 | Use refresh serialization/generation guards and preserve valid prior state when later refreshes fail. | ✅ | 2026-09-26 |
| TASK-016 | Await persistence, refresh, and state publication for query, add, URI-add, and delete operations. | ✅ | 2026-09-26 |
| TASK-017 | Render loading/error/empty account states without converting initialization errors into a false empty state. | ✅ | 2026-09-26 |
| TASK-018 | Handle missing detail accounts safely and delete by canonical account ID. | ✅ | 2026-09-26 |
| TASK-019 | Pass canonical account IDs through deletion dialogs, routes, and controller operations. | ✅ | 2026-09-26 |
| DONE-003 | Cold start and account mutations have deterministic completion semantics and do not present failed initialization as an empty account list. | ✅ | 2026-09-26 |

### Implementation Phase 4

- GOAL-004: Close the QR/manual UI lifecycle race and preserve user-visible error behavior.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-020 | Await QR `addAccountFromUri()` persistence/state completion before navigating and reset the duplicate-scan guard on handled failures. | ✅ | 2026-09-26 |
| TASK-021 | Await manual account persistence, navigate only after success, and keep the form open on sanitized persistence failure. | ✅ | 2026-09-26 |
| TASK-022 | Distinguish persistence failures from invalid QR/manual input in user-facing error handling. | ✅ | 2026-09-26 |
| TASK-023 | Reload/refresh account state before restarting lifecycle-driven refresh behavior and preserve valid state on transient failure. | ✅ | 2026-09-26 |
| DONE-004 | QR/manual additions persist before navigation and storage failures are not mislabeled as parse failures. | ✅ | 2026-09-26 |

### Implementation Phase 5

- GOAL-005: Add regression coverage for persistence, restart hydration, migration, and failure handling.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-024 | Cover authoritative round-trip, Base32 validation, verification cleanup, migration, missing secrets, malformed records, and deletion with an in-memory backend. | ✅ | 2026-09-26 |
| TASK-025 | Cover URI-derived account persistence, query filtering, canonical identifiers, and new-service reload behavior. | ✅ | 2026-09-26 |
| TASK-026 | Cover RFC 6238 vectors, authoritative secret lookup, and missing/corrupt-record failures. | ✅ | 2026-09-26 |
| TASK-027 | Cover initial load, awaited refresh, serialized operations, refresh-error preservation, and provider recreation. | ✅ | 2026-09-26 |
| TASK-028 | Replace the counter-template widget test with bootstrap and unsupported-platform-surface coverage. | ✅ | 2026-09-26 |
| TASK-029 | Add real-storage integration coverage for QR decoding, service recreation, HOTP counter persistence, and collision-safe deletion; process-death/lifecycle coverage remains external. | ⚠️ | 2026-09-26 |
| TASK-030 | Run code generation, analysis, formatting, host tests, and the iOS simulator integration suite; Android device execution remains pending. | ⚠️ | 2026-09-26 |
| DONE-005 | Automated and iOS-simulator coverage proves verified persistence, migration behavior, QR-derived account durability across service recreation, and sanitized failure handling. | ⚠️ | 2026-09-26 |

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
