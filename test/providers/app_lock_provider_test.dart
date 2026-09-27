import 'dart:async';

import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/app_lock_provider.dart';
import 'package:cipher/src/providers/secure_clipboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('coalesces authentication and remains locked on failure', () async {
    final authentication = Completer<BiometricAuthStatus>();
    var calls = 0;
    final container = _createContainer(
      biometricEnabled: true,
      authenticator: () {
        calls++;
        return authentication.future;
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(appLockControllerProvider.notifier);
    final first = controller.authenticate();
    final second = controller.authenticate();

    expect(calls, 1);
    expect(controller.state, AppLockStatus.authenticating);

    authentication.complete(BiometricAuthStatus.failure);

    expect(await first, BiometricAuthStatus.failure);
    expect(await second, BiometricAuthStatus.failure);
    expect(controller.state, AppLockStatus.locked);
  });

  test('unlocks only after successful authentication', () async {
    final container = _createContainer(
      biometricEnabled: true,
      authenticator: () async => BiometricAuthStatus.success,
    );
    addTearDown(container.dispose);

    final controller = container.read(appLockControllerProvider.notifier);

    expect(await controller.authenticate(), BiometricAuthStatus.success);
    expect(controller.state, AppLockStatus.unlocked);
  });

  test('lifecycle lock clears the managed clipboard', () async {
    final values = <String>[];
    final clipboard = SecureClipboardService(
      writer: (value) async => values.add(value),
    );
    final container = _createContainer(
      biometricEnabled: true,
      authenticator: () async => BiometricAuthStatus.success,
      clipboard: clipboard,
    );
    addTearDown(container.dispose);

    final controller = container.read(appLockControllerProvider.notifier);
    await controller.authenticate();
    await clipboard.copy('123456', timeoutMilliseconds: 60000);

    controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state, AppLockStatus.locked);
    expect(values.last, '');
  });

  test('disabled biometrics unlock without invoking authentication', () async {
    var called = false;
    final container = _createContainer(
      biometricEnabled: false,
      authenticator: () async {
        called = true;
        return BiometricAuthStatus.failure;
      },
    );
    addTearDown(container.dispose);

    final controller = container.read(appLockControllerProvider.notifier);

    expect(await controller.authenticate(), BiometricAuthStatus.disabled);
    expect(controller.state, AppLockStatus.unlocked);
    expect(called, isFalse);
  });
}

ProviderContainer _createContainer({
  required bool biometricEnabled,
  required BiometricAuthenticator authenticator,
  SecureClipboardService? clipboard,
}) {
  final container = ProviderContainer(
    overrides: [
      biometricAuthenticatorProvider.overrideWithValue(authenticator),
      if (clipboard != null)
        secureClipboardServiceProvider.overrideWithValue(clipboard),
    ],
  );
  container
      .read(settingsControllerProvider.notifier)
      .state = SettingsState.loaded(
    Settings(
      themeMode: ThemeMode.system,
      clipboardTimeout: 1000,
      biometricAuthEnabled: biometricEnabled,
    ),
  );
  return container;
}
