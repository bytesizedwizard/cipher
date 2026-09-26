import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('persists account across storage service recreation', (
    tester,
  ) async {
    final service = AccountStorageService(
      backend: StorageServiceAccountStorageBackend(_newStorageService()),
    );
    final account = Account(
      label: 'integration@example.com',
      issuer: 'CipherIntegrationTest',
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
      type: 'totp',
    );

    await service.delete(account);
    await service.save(account, 'JBSWY3DPEHPK3PXP');

    final reloaded = AccountStorageService(
      backend: StorageServiceAccountStorageBackend(_newStorageService()),
    );
    final result = await reloaded.loadAll();

    expect(result.accounts.map((value) => value.id), contains(account.id));

    await reloaded.delete(account);
  });
}

StorageService _newStorageService() {
  return StorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
    SharedPreferencesAsync(),
  );
}
