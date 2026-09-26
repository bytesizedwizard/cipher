import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/services/auth_service.dart';
import 'package:cipher/src/feature/account/utils/account_storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';

import 'account_storage_service_test.dart';

void main() {
  test('account added through service survives service recreation', () async {
    final backend = FakeAccountStorageBackend();
    final account = testAccount();
    final firstService = AuthService(
      accountStorageService: AccountStorageService(backend: backend),
    );

    await firstService.addAccount(account, 'JBSWY3DPEHPK3PXP');

    final secondService = AuthService(
      accountStorageService: AccountStorageService(backend: backend),
    );
    final accounts = await secondService.getAccounts('');

    expect(accounts.single.id, 'Example:alice@example.com');
    expect(
      accounts.single.storageId,
      authoritativeAccountStorageKey(account.issuer, account.label),
    );
    expect(await secondService.getAccounts('alice@example.com'), hasLength(1));
  });
}
