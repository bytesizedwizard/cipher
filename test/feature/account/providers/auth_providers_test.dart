import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/feature/account/services/account_storage_service.dart';
import 'package:cipher/src/feature/account/services/auth_service.dart';
import 'package:cipher/src/feature/account/services/totp_service.dart';
import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/app_lock_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../services/account_storage_service_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('hydrates persisted accounts after provider recreation', () async {
    final backend = FakeAccountStorageBackend();
    final firstContainer = createContainer(backend);
    addTearDown(firstContainer.dispose);

    await firstContainer.read(authControllerProvider.future);
    await firstContainer
        .read(authControllerProvider.notifier)
        .addAccount(testAccount(), 'JBSWY3DPEHPK3PXP');

    final firstState = firstContainer.read(authControllerProvider);
    expect(firstState.value, contains(testAccount().id));

    final secondContainer = createContainer(backend);
    addTearDown(secondContainer.dispose);
    await secondContainer.read(authControllerProvider.future);

    final secondState = secondContainer.read(authControllerProvider);
    expect(secondState.value, contains(testAccount().id));
  });

  test('persists accounts added from an otpauth URI', () async {
    final backend = FakeAccountStorageBackend();
    final container = createContainer(backend);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .addAccountFromUri(
          'otpauth://totp/Example:qr@example.com'
          '?secret=JBSWY3DPEHPK3PXP&issuer=Example',
        );

    final state = container.read(authControllerProvider);
    expect(state.value?.values.single.account.label, 'qr@example.com');
  });

  test('keeps valid state when later refresh fails', () async {
    final backend = FakeAccountStorageBackend();
    final container = createContainer(backend);
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .addAccount(testAccount(), 'JBSWY3DPEHPK3PXP');
    backend.corruptReadKey = testAccount().storageId;

    await expectLater(
      container.read(authControllerProvider.notifier).refreshAccounts(''),
      throwsA(isA<Object>()),
    );

    final state = container.read(authControllerProvider);
    expect(state.hasError, isTrue);
    expect(state.value, isNotEmpty);
  });

  test('redacts OTP-bearing state when the app locks', () async {
    final backend = FakeAccountStorageBackend();
    final storage = AccountStorageService(backend: backend);
    final auth = AuthService(accountStorageService: storage);
    final totp = TotpService(accountStorageService: storage);
    await auth.addAccount(testAccount(), 'JBSWY3DPEHPK3PXP');

    final container = ProviderContainer(
      overrides: [
        accountStorageServiceProvider.overrideWithValue(storage),
        authServiceProvider.overrideWithValue(auth),
        totpServiceProvider.overrideWithValue(totp),
        biometricAuthenticatorProvider.overrideWithValue(
          () async => BiometricAuthStatus.success,
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(settingsControllerProvider.notifier)
        .state = SettingsState.loaded(
      Settings(
        themeMode: ThemeMode.system,
        clipboardTimeout: 1000,
        biometricAuthEnabled: true,
      ),
    );

    await container.read(authControllerProvider.future);
    final lock = container.read(appLockControllerProvider.notifier);
    await lock.authenticate();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, isNotEmpty);

    lock.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(authControllerProvider).value, isEmpty);
  });
}

ProviderContainer createContainer(FakeAccountStorageBackend backend) {
  final storage = AccountStorageService(backend: backend);
  final auth = AuthService(accountStorageService: storage);
  final totp = TotpService(accountStorageService: storage);

  return ProviderContainer(
    overrides: [
      accountStorageServiceProvider.overrideWithValue(storage),
      authServiceProvider.overrideWithValue(auth),
      totpServiceProvider.overrideWithValue(totp),
      appLockControllerProvider.overrideWithValue(AppLockStatus.unlocked),
    ],
  );
}
