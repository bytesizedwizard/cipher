import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'storage_service.g.dart';

enum StorageSource { secureStorage, sharedPreferences }

/// Service for handling storage operations
///
/// Provides helper methods for storing and retrieving sensitive data
/// like authentication tokens and user IDs.
class StorageService {
  StorageService(this._secureStorage, this._sharedPreferencesAsync);

  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync _sharedPreferencesAsync;

  Future<void> write(String key, String value, StorageSource source) async {
    if (source == StorageSource.secureStorage) {
      await _secureStorage.write(key: key, value: value);
    } else {
      await _sharedPreferencesAsync.setString(key, value);
    }
  }

  Future<String?> read(String key, StorageSource source) async {
    if (source == StorageSource.secureStorage) {
      return await _secureStorage.read(key: key);
    } else {
      return await _sharedPreferencesAsync.getString(key);
    }
  }

  Future<Map<String, Object?>> readAll({required StorageSource source}) async {
    if (source == StorageSource.secureStorage) {
      return await _secureStorage.readAll();
    } else {
      return await _sharedPreferencesAsync.getAll();
    }
  }

  Future<void> delete(String key, StorageSource source) async {
    if (source == StorageSource.secureStorage) {
      await _secureStorage.delete(key: key);
    } else {
      await _sharedPreferencesAsync.remove(key);
    }
  }

  Future<void> deleteAll({required StorageSource source}) async {
    if (source == StorageSource.secureStorage) {
      await _secureStorage.deleteAll();
    } else {
      await _sharedPreferencesAsync.clear();
    }
  }
}

// Riverpod providers for SecureStorageService and FlutterSecureStorage

@Riverpod(keepAlive: true)
FlutterSecureStorage _secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
}

@Riverpod(keepAlive: true)
SharedPreferencesAsync _sharedPreferencesAsync(Ref ref) {
  return SharedPreferencesAsync();
}

@Riverpod(keepAlive: true)
StorageService storageService(Ref ref) {
  final secureStorage = ref.watch(_secureStorageProvider);
  final sharedPreferences = ref.watch(_sharedPreferencesAsyncProvider);

  return StorageService(secureStorage, sharedPreferences);
}
