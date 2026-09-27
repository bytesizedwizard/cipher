import 'dart:convert';

import 'package:base32/base32.dart';
import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/models/stored_account.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/account/utils/account_storage_keys.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_storage_service.g.dart';

const int currentStoredAccountVersion = 2;

abstract interface class AccountStorageBackend {
  Future<void> writeSecure(String key, String value);

  Future<String?> readSecure(String key);

  Future<Map<String, Object?>> readAllSecure();

  Future<void> deleteSecure(String key);

  Future<String?> readPreference(String key);

  Future<Map<String, Object?>> readAllPreferences();

  Future<void> deletePreference(String key);
}

class StorageServiceAccountStorageBackend implements AccountStorageBackend {
  const StorageServiceAccountStorageBackend(this._storageService);

  final StorageService _storageService;

  @override
  Future<void> writeSecure(String key, String value) {
    return _storageService.write(key, value, StorageSource.secureStorage);
  }

  @override
  Future<String?> readSecure(String key) {
    return _storageService.read(key, StorageSource.secureStorage);
  }

  @override
  Future<Map<String, Object?>> readAllSecure() {
    return _storageService.readAll(source: StorageSource.secureStorage);
  }

  @override
  Future<void> deleteSecure(String key) {
    return _storageService.delete(key, StorageSource.secureStorage);
  }

  @override
  Future<String?> readPreference(String key) {
    return _storageService.read(key, StorageSource.sharedPreferences);
  }

  @override
  Future<Map<String, Object?>> readAllPreferences() {
    return _storageService.readAll(source: StorageSource.sharedPreferences);
  }

  @override
  Future<void> deletePreference(String key) {
    return _storageService.delete(key, StorageSource.sharedPreferences);
  }
}

class AccountStorageLoadResult {
  const AccountStorageLoadResult({required this.records, required this.issues});

  final List<StoredAccountRecord> records;
  final List<AccountStorageIssue> issues;

  List<Account> get accounts =>
      records.map((record) => record.account).toList();
}

class AccountStorageService {
  AccountStorageService({required AccountStorageBackend backend})
    : _backend = backend;

  final AccountStorageBackend _backend;

  Future<void> save(Account account, String secret) async {
    _validateAccount(account, account.id);
    _validateSecret(secret, account.id);

    final record = StoredAccountRecord(
      account: account.copyWith(otp: null),
      encodedSecret: base64Encode(utf8.encode(secret.trim())),
      version: currentStoredAccountVersion,
    );

    await _writeAndVerify(
      account.storageId,
      record,
      account.id,
      writeFailureCode: AccountStorageIssueCode.writeFailed,
      verificationFailureCode: AccountStorageIssueCode.verificationFailed,
    );
  }

  Future<void> updateCounter(Account account, int counter) async {
    if (account.type != AuthConstants.hotp || counter < 0) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidRecord,
        operation: 'updateCounter',
        accountId: account.id,
      );
    }

    final encoded = await _readSecure(
      account.storageId,
      account.id,
      'updateCounter',
    );
    if (encoded == null) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.missingSecret,
        operation: 'updateCounter',
        accountId: account.id,
      );
    }

    final stored = _decodeRecord(encoded, 'updateCounter');
    if (stored.account.id != account.id) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidRecord,
        operation: 'updateCounter',
        accountId: account.id,
      );
    }

    final updated = stored.copyWith(
      account: stored.account.copyWith(counter: counter, otp: null),
      version: currentStoredAccountVersion,
    );
    await _writeAndVerify(
      account.storageId,
      updated,
      account.id,
      writeFailureCode: AccountStorageIssueCode.writeFailed,
      verificationFailureCode: AccountStorageIssueCode.verificationFailed,
    );
  }

  Future<AccountStorageLoadResult> loadAll() async {
    final Map<String, Object?> all;
    try {
      all = await _backend.readAllSecure();
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.readFailed,
        operation: 'loadAll',
      );
    }

    final records = <StoredAccountRecord>[];
    final issues = <AccountStorageIssue>[];

    for (final entry in all.entries) {
      if (!isAuthoritativeAccountStorageKey(entry.key)) {
        continue;
      }

      try {
        if (entry.value is! String) {
          throw AccountStorageIssue(
            code: AccountStorageIssueCode.invalidRecord,
            operation: 'loadAll',
          );
        }

        final encoded = entry.value! as String;
        final record = _decodeRecord(encoded, 'loadAll');
        if (record.account.storageId != entry.key) {
          throw AccountStorageIssue(
            code: AccountStorageIssueCode.invalidRecord,
            operation: 'loadAll',
            accountId: record.account.id,
          );
        }
        records.add(record);
        final storedVersion = _recordVersion(encoded);
        if (storedVersion != null &&
            storedVersion != currentStoredAccountVersion) {
          try {
            await _writeAndVerify(
              entry.key,
              record,
              record.account.id,
              writeFailureCode: AccountStorageIssueCode.migrationFailed,
              verificationFailureCode: AccountStorageIssueCode.migrationFailed,
            );
          } on AccountStorageIssue catch (issue) {
            issues.add(issue);
          }
        }
      } on AccountStorageIssue catch (issue) {
        issues.add(issue);
      } on Object {
        issues.add(
          AccountStorageIssue(
            code: AccountStorageIssueCode.invalidRecord,
            operation: 'loadAll',
          ),
        );
      }
    }

    return AccountStorageLoadResult(records: records, issues: issues);
  }

  Future<String> readSecret(Account account) async {
    final authoritativeKey = account.storageId;
    final authoritativeValue = await _readSecure(
      authoritativeKey,
      account.id,
      'readSecret',
    );

    if (authoritativeValue != null) {
      final record = _decodeRecord(authoritativeValue, 'readSecret');
      if (record.account.id != account.id) {
        throw AccountStorageIssue(
          code: AccountStorageIssueCode.invalidRecord,
          operation: 'readSecret',
          accountId: account.id,
        );
      }
      final storedVersion = _recordVersion(authoritativeValue);
      if (storedVersion != null &&
          storedVersion != currentStoredAccountVersion) {
        await _writeAndVerify(
          authoritativeKey,
          record,
          account.id,
          writeFailureCode: AccountStorageIssueCode.migrationFailed,
          verificationFailureCode: AccountStorageIssueCode.migrationFailed,
        );
      }
      return _decodeStoredSecret(record.encodedSecret, account.id);
    }

    final legacyValue = await _readSecure(
      legacySecretStorageKey(account.legacyId),
      account.id,
      'readSecret',
    );
    if (legacyValue == null || legacyValue.isEmpty) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.missingSecret,
        operation: 'readSecret',
        accountId: account.id,
      );
    }

    return _decodeStoredSecret(legacyValue, account.id);
  }

  Future<List<AccountStorageIssue>> migrateLegacyAccounts() async {
    final Map<String, Object?> all;
    try {
      all = await _backend.readAllPreferences();
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.migrationFailed,
        operation: 'migrateLegacyAccounts',
      );
    }

    final issues = <AccountStorageIssue>[];

    for (final entry in all.entries) {
      if (entry.key == SettingsConstants.storageKey ||
          !entry.key.contains(':') ||
          entry.value is! String) {
        continue;
      }

      Account account;
      try {
        final decoded = jsonDecode(entry.value! as String);
        if (decoded is! Map) {
          continue;
        }
        account = Account.fromJson(Map<String, Object?>.from(decoded));
      } on Object {
        issues.add(
          AccountStorageIssue(
            code: AccountStorageIssueCode.migrationFailed,
            operation: 'migrateLegacyAccounts',
            accountId: entry.key,
          ),
        );
        continue;
      }

      if (account.legacyId != entry.key) {
        issues.add(
          AccountStorageIssue(
            code: AccountStorageIssueCode.migrationFailed,
            operation: 'migrateLegacyAccounts',
            accountId: entry.key,
          ),
        );
        continue;
      }

      try {
        final existing = await _readSecure(
          account.storageId,
          account.id,
          'migrateLegacyAccounts',
        );
        if (existing != null) {
          try {
            _decodeRecord(existing, 'migrateLegacyAccounts');
            await _deleteLegacyAccount(account.legacyId);
            continue;
          } on AccountStorageIssue {
            // Replace invalid authoritative data with verified legacy data.
          }
        }

        final legacySecret = await _readSecure(
          legacySecretStorageKey(account.legacyId),
          account.id,
          'migrateLegacyAccounts',
        );
        if (legacySecret == null || legacySecret.isEmpty) {
          throw AccountStorageIssue(
            code: AccountStorageIssueCode.missingSecret,
            operation: 'migrateLegacyAccounts',
            accountId: account.id,
          );
        }

        final secret = _decodeStoredSecret(legacySecret, account.id);
        final record = StoredAccountRecord(
          account: account.copyWith(otp: null),
          encodedSecret: base64Encode(utf8.encode(secret)),
          version: currentStoredAccountVersion,
        );

        await _writeAndVerify(
          account.storageId,
          record,
          account.id,
          writeFailureCode: AccountStorageIssueCode.migrationFailed,
          verificationFailureCode: AccountStorageIssueCode.migrationFailed,
        );
        await _deleteLegacyAccount(account.legacyId);
      } on AccountStorageIssue catch (issue) {
        issues.add(issue);
      } on Object {
        issues.add(
          AccountStorageIssue(
            code: AccountStorageIssueCode.migrationFailed,
            operation: 'migrateLegacyAccounts',
            accountId: account.id,
          ),
        );
      }
    }

    return issues;
  }

  Future<void> delete(Account account) => deleteById(account.id);

  Future<void> deleteById(String accountId) async {
    try {
      final all = await _backend.readAllSecure();
      final legacyIds = <String>{};
      for (final entry in all.entries) {
        if (!isAuthoritativeAccountStorageKey(entry.key) ||
            entry.value is! String) {
          continue;
        }

        try {
          final decoded = jsonDecode(entry.value! as String);
          if (decoded is! Map || decoded['account'] is! Map) {
            continue;
          }
          final account = Account.fromJson(
            Map<String, Object?>.from(decoded['account'] as Map),
          );
          if (account.id == accountId || account.legacyId == accountId) {
            await _backend.deleteSecure(entry.key);
            legacyIds.add(account.legacyId);
          }
        } on Object {
          // Ignore unrelated malformed records while deleting this account.
        }
      }
      if (!isAuthoritativeAccountStorageKey(accountId)) {
        legacyIds.add(accountId);
      }
      for (final legacyId in legacyIds) {
        await _backend.deleteSecure(legacySecretStorageKey(legacyId));
        await _backend.deletePreference(legacyId);
      }
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.deleteFailed,
        operation: 'delete',
        accountId: accountId,
      );
    }
  }

  Future<void> _writeAndVerify(
    String storageKey,
    StoredAccountRecord record,
    String accountId, {
    required AccountStorageIssueCode writeFailureCode,
    required AccountStorageIssueCode verificationFailureCode,
  }) async {
    final encoded = jsonEncode(record.toJson());
    try {
      await _backend.writeSecure(storageKey, encoded);
    } on Object {
      throw AccountStorageIssue(
        code: writeFailureCode,
        operation: 'write',
        accountId: accountId,
      );
    }

    try {
      final stored = await _backend.readSecure(storageKey);
      if (stored == null) {
        throw StateError('missing record');
      }
      final verified = _decodeRecord(stored, 'verify');
      if (verified.account.id != accountId ||
          verified.encodedSecret != record.encodedSecret ||
          verified.version != record.version) {
        throw StateError('record mismatch');
      }
    } on Object {
      try {
        await _backend.deleteSecure(storageKey);
      } on Object {
        // Preserve verification failure and never expose backend details.
      }
      throw AccountStorageIssue(
        code: verificationFailureCode,
        operation: 'verify',
        accountId: accountId,
      );
    }
  }

  Future<String?> _readSecure(
    String key,
    String accountId,
    String operation,
  ) async {
    try {
      return await _backend.readSecure(key);
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.readFailed,
        operation: operation,
        accountId: accountId,
      );
    }
  }

  Future<void> _deleteLegacyAccount(String accountId) async {
    try {
      await _backend.deletePreference(accountId);
      await _backend.deleteSecure(legacySecretStorageKey(accountId));
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.migrationFailed,
        operation: 'migrateLegacyAccounts',
        accountId: accountId,
      );
    }
  }

  StoredAccountRecord _decodeRecord(String encoded, String operation) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) {
        throw StateError('record is not an object');
      }

      final record = StoredAccountRecord.fromJson(
        Map<String, Object?>.from(decoded),
      );
      final migrated = switch (record.version) {
        1 => record.copyWith(version: currentStoredAccountVersion),
        currentStoredAccountVersion => record,
        _ => throw StateError('unsupported record version'),
      };
      if (migrated.version != currentStoredAccountVersion) {
        throw StateError('unsupported record version');
      }
      _validateAccount(migrated.account, migrated.account.id);
      _decodeStoredSecret(migrated.encodedSecret, migrated.account.id);
      return migrated;
    } on AccountStorageIssue {
      rethrow;
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidRecord,
        operation: operation,
      );
    }
  }

  int? _recordVersion(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is Map && decoded['version'] is num) {
      return (decoded['version'] as num).toInt();
    }
    return null;
  }

  String _decodeStoredSecret(String encoded, String accountId) {
    if (encoded.isEmpty) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.missingSecret,
        operation: 'decodeSecret',
        accountId: accountId,
      );
    }

    try {
      final secret = utf8.decode(base64Decode(encoded));
      _validateSecret(secret, accountId);
      return secret;
    } on AccountStorageIssue {
      rethrow;
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidSecret,
        operation: 'decodeSecret',
        accountId: accountId,
      );
    }
  }

  void _validateSecret(String secret, String accountId) {
    final normalized = secret
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('=', '')
        .toUpperCase();
    if (normalized.isEmpty) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidSecret,
        operation: 'validateSecret',
        accountId: accountId,
      );
    }

    try {
      if (base32.decode(normalized).isEmpty) {
        throw StateError('empty secret');
      }
    } on AccountStorageIssue {
      rethrow;
    } on Object {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidSecret,
        operation: 'validateSecret',
        accountId: accountId,
      );
    }
  }

  void _validateAccount(Account account, String accountId) {
    final validAlgorithm =
        account.algorithm == AuthConstants.algorithmSHA1 ||
        account.algorithm == AuthConstants.algorithmSHA256 ||
        account.algorithm == AuthConstants.algorithmSHA512;
    final validType =
        account.type == AuthConstants.totp ||
        account.type == AuthConstants.hotp;

    if (account.label.isEmpty ||
        !validAlgorithm ||
        !validType ||
        account.digits <= 0 ||
        account.period <= 0 ||
        account.counter < 0) {
      throw AccountStorageIssue(
        code: AccountStorageIssueCode.invalidRecord,
        operation: 'validateAccount',
        accountId: accountId,
      );
    }
  }
}

@Riverpod(keepAlive: true)
AccountStorageService accountStorageService(Ref ref) {
  final storageService = ref.read(storageServiceProvider);
  return AccountStorageService(
    backend: StorageServiceAccountStorageBackend(storageService),
  );
}
