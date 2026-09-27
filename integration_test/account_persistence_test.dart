import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/services/auth_service.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/account/services/totp_service.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
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

  testWidgets('persists a QR-decoded account across service recreation', (
    tester,
  ) async {
    final storage = AccountStorageService(
      backend: StorageServiceAccountStorageBackend(_newStorageService()),
    );
    final auth = AuthService(accountStorageService: storage);
    final totp = TotpService(accountStorageService: storage);
    final (account, secret) = totp.decode(
      'otpauth://totp/Cipher:integration%40example.com'
      '?secret=JBSWY3DPEHPK3PXP&issuer=Cipher',
    );

    await storage.delete(account);
    await auth.addAccount(account, secret);

    final reloaded = AuthService(
      accountStorageService: AccountStorageService(
        backend: StorageServiceAccountStorageBackend(_newStorageService()),
      ),
    );
    final accounts = await reloaded.getAccounts('');

    expect(accounts.map((value) => value.id), contains(account.id));

    await reloaded.deleteAccount(account.id);
  });

  testWidgets('persists HOTP advancement and isolates collision-safe IDs', (
    tester,
  ) async {
    final storage = AccountStorageService(
      backend: StorageServiceAccountStorageBackend(_newStorageService()),
    );
    final auth = AuthService(accountStorageService: storage);
    final hotp = Account(
      label: 'counter',
      issuer: 'CipherIntegration',
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
      type: AuthConstants.hotp,
      counter: 0,
    );
    final first = Account(
      label: 'Account',
      issuer: 'Example:Issuer',
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
      type: AuthConstants.totp,
    );
    final second = Account(
      label: 'Issuer:Account',
      issuer: 'Example',
      algorithm: 'SHA1',
      digits: 6,
      period: 30,
      type: AuthConstants.totp,
    );

    await storage.delete(hotp);
    await storage.delete(first);
    await storage.delete(second);
    await auth.addAccount(hotp, 'JBSWY3DPEHPK3PXP');
    await auth.addAccount(first, 'JBSWY3DPEHPK3PXP');
    await auth.addAccount(second, 'JBSWY3DPEHPK3PXP');

    await auth.advanceHotp(hotp.id);
    final accounts = await auth.getAccounts('');
    expect(accounts.singleWhere((value) => value.id == hotp.id).counter, 1);
    expect(first.id, isNot(second.id));
    expect(first.legacyId, second.legacyId);

    await auth.deleteAccount(first.id);
    final remaining = await auth.getAccounts('');
    expect(remaining.map((value) => value.id), isNot(contains(first.id)));
    expect(remaining.map((value) => value.id), contains(second.id));

    await auth.deleteAccount(hotp.id);
    await auth.deleteAccount(second.id);
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
