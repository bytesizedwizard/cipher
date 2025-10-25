import 'dart:convert';

import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

class AuthService {
  const AuthService({required StorageService storageService})
    : _storageService = storageService;

  final StorageService _storageService;

  /// Retrieves all stored Account objects from the storage service.
  /// Returns an empty list if no accounts are found.
  Future<List<Account>> getAccounts(String query) async {
    final Map<String, Object?> all = await _storageService.readAll(
      source: StorageSource.sharedPreferences,
    );

    List<Account> accounts = [];

    for (var entry in all.entries) {
      try {
        final value = entry.value;
        if (value == null || entry.key == SettingsConstants.storageKey) {
          continue;
        }

        Account account = Account.fromJson(json.decode(value.toString()));

        if (query.isNotEmpty) {
          bool matches = true;

          final accountValue = account.toJson().toString().toLowerCase();
          if (!accountValue.contains(query.toLowerCase())) {
            matches = false;
          }

          if (!matches) {
            continue;
          }
        }

        accounts.add(account);
      } catch (e) {
        rethrow;
      }
    }

    return accounts;
  }

  /// Adds a new Account along with its secret to the storage service.
  /// The account is stored in shared preferences, while the secret is stored
  /// in secure storage.
  /// The key for storage is constructed as "issuer:label".
  Future<void> addAccount(Account account, String secret) async {
    final String key = "${account.issuer}:${account.label}";
    final String value = json.encode(account.toJson());

    // Store account metadata in shared preferences
    await _storageService.write(key, value, StorageSource.sharedPreferences);

    // Store secret securely in secure storage
    await _storageService.write(
      "${key}_secret",
      base64Encode(utf8.encode(secret)),
      StorageSource.secureStorage,
    );
  }

  /// Deletes an Account and its associated secret from the storage service.
  /// The account metadata is removed from shared preferences, and the secret
  /// is removed from secure storage.
  Future<void> deleteAccount(String id) async {
    // Remove account metadata from shared preferences
    await _storageService.delete(id, StorageSource.sharedPreferences);

    // Remove secret from secure storage
    await _storageService.delete("${id}_secret", StorageSource.secureStorage);
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final storageService = ref.watch(storageServiceProvider);

  return AuthService(storageService: storageService);
}
