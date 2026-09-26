import 'dart:convert';

import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/models/stored_account.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/utils/account_storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const secret = 'JBSWY3DPEHPK3PXP';

  group('AccountStorageService', () {
    test('saves verified records readable by a new service instance', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      final service = AccountStorageService(backend: backend);

      await service.save(account, secret);

      final reloaded = AccountStorageService(backend: backend);
      final result = await reloaded.loadAll();

      expect(result.issues, isEmpty);
      expect(result.accounts, hasLength(1));
      expect(result.accounts.single.id, account.id);
      expect(
        backend.secure[authoritativeAccountStorageKey(
          account.issuer,
          account.label,
        )],
        isA<String>(),
      );
    });

    test('uses distinct keys for reserved characters in issuer and label', () {
      final first = Account(
        label: 'c',
        issuer: 'a:b',
        algorithm: 'SHA1',
        digits: 6,
        period: 30,
        type: 'totp',
      );
      final second = Account(
        label: 'b:c',
        issuer: 'a',
        algorithm: 'SHA1',
        digits: 6,
        period: 30,
        type: 'totp',
      );

      expect(first.storageId, isNot(second.storageId));
    });

    test('round-trips stored records without transient OTP', () {
      final account = testAccount()..otp = '123456';
      final record = StoredAccountRecord(
        account: account.copyWith(otp: null),
        encodedSecret: base64Encode(utf8.encode(secret)),
        version: currentStoredAccountVersion,
      );

      final decoded = StoredAccountRecord.fromJson(record.toJson());

      expect(decoded.account.id, account.id);
      expect(decoded.account.otp, isNull);
      expect(decoded.encodedSecret, record.encodedSecret);
      expect(decoded.version, currentStoredAccountVersion);
    });

    test('removes a record when write verification fails', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      backend.corruptReadKey = account.storageId;
      final service = AccountStorageService(backend: backend);

      await expectLater(
        service.save(account, secret),
        throwsA(
          isA<AccountStorageIssue>().having(
            (issue) => issue.code,
            'code',
            AccountStorageIssueCode.verificationFailed,
          ),
        ),
      );
      expect(backend.secure.containsKey(account.storageId), isFalse);
    });

    test('isolates malformed authoritative records', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      final service = AccountStorageService(backend: backend);
      await service.save(account, secret);
      backend.secure['account:malformed'] = 'not-json';

      final result = await service.loadAll();

      expect(result.accounts.single.id, account.id);
      expect(result.issues, hasLength(1));
    });

    test('migrates legacy split records idempotently', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      backend.preferences[account.id] = jsonEncode(account.toJson());
      backend.secure[legacySecretStorageKey(account.id)] = base64Encode(
        utf8.encode(secret),
      );
      final service = AccountStorageService(backend: backend);

      expect(await service.migrateLegacyAccounts(), isEmpty);
      expect(backend.preferences.containsKey(account.id), isFalse);
      expect(
        backend.secure.containsKey(legacySecretStorageKey(account.id)),
        isFalse,
      );
      expect(backend.secure.containsKey(account.storageId), isTrue);
      expect(await service.migrateLegacyAccounts(), isEmpty);
      expect(await service.readSecret(account), secret);
    });

    test('retains legacy metadata when secret is missing', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      backend.preferences[account.id] = jsonEncode(account.toJson());
      final service = AccountStorageService(backend: backend);

      final issues = await service.migrateLegacyAccounts();

      expect(issues.single.code, AccountStorageIssueCode.missingSecret);
      expect(backend.preferences.containsKey(account.id), isTrue);
    });

    test('deletes authoritative and legacy records', () async {
      final backend = FakeAccountStorageBackend();
      final account = testAccount();
      final service = AccountStorageService(backend: backend);
      await service.save(account, secret);
      backend.preferences[account.id] = jsonEncode(account.toJson());
      backend.secure[legacySecretStorageKey(account.id)] = base64Encode(
        utf8.encode(secret),
      );

      await service.delete(account);

      expect(backend.preferences.containsKey(account.id), isFalse);
      expect(backend.secure.containsKey(account.storageId), isFalse);
      expect(
        backend.secure.containsKey(legacySecretStorageKey(account.id)),
        isFalse,
      );
    });
  });
}

Account testAccount() {
  return Account(
    label: 'alice@example.com',
    issuer: 'Example',
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
    type: 'totp',
  );
}

class FakeAccountStorageBackend implements AccountStorageBackend {
  final secure = <String, Object?>{};
  final preferences = <String, Object?>{};
  String? corruptReadKey;

  @override
  Future<void> writeSecure(String key, String value) async {
    secure[key] = value;
  }

  @override
  Future<String?> readSecure(String key) async {
    if (key == corruptReadKey) {
      return '{}';
    }
    final value = secure[key];
    return value is String ? value : null;
  }

  @override
  Future<Map<String, Object?>> readAllSecure() async {
    return Map<String, Object?>.from(secure);
  }

  @override
  Future<void> deleteSecure(String key) async {
    secure.remove(key);
  }

  @override
  Future<String?> readPreference(String key) async {
    final value = preferences[key];
    return value is String ? value : null;
  }

  @override
  Future<Map<String, Object?>> readAllPreferences() async {
    return Map<String, Object?>.from(preferences);
  }

  @override
  Future<void> deletePreference(String key) async {
    preferences.remove(key);
  }
}
