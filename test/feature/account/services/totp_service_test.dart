import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/services/totp_service.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'account_storage_service_test.dart';

void main() {
  test('generates RFC 6238 SHA1 vector', () async {
    final service = TotpService(
      accountStorageService: AccountStorageService(
        backend: FakeAccountStorageBackend(),
      ),
    );

    final otp = await service.generateTotp(
      secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
      digits: 8,
      period: 30,
      algorithm: 'SHA1',
      forTime: DateTime.fromMillisecondsSinceEpoch(59 * 1000, isUtc: true),
    );

    expect(otp, '94287082');
  });

  test('refreshes from authoritative account storage', () async {
    final backend = FakeAccountStorageBackend();
    final storage = AccountStorageService(backend: backend);
    final account = testAccount();
    await storage.save(account, 'JBSWY3DPEHPK3PXP');
    final service = TotpService(accountStorageService: storage);

    final otp = await service.refresh(account);

    expect(otp, hasLength(account.digits));
    expect(otp, matches(RegExp(r'^\d+$')));
  });

  test('reports missing stored secret', () async {
    final storage = AccountStorageService(backend: FakeAccountStorageBackend());
    final service = TotpService(accountStorageService: storage);

    await expectLater(
      service.refresh(testAccount()),
      throwsA(
        isA<AccountStorageIssue>().having(
          (issue) => issue.code,
          'code',
          AccountStorageIssueCode.missingSecret,
        ),
      ),
    );
  });
}
