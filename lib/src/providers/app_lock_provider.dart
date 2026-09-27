import 'dart:async';

import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/secure_clipboard_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lock_provider.g.dart';

enum AppLockStatus { locked, authenticating, unlocked }

typedef BiometricAuthenticator = Future<BiometricAuthStatus> Function();

final biometricAuthenticatorProvider = Provider<BiometricAuthenticator>((ref) {
  return () => ref.read(settingsControllerProvider.notifier).authenticate();
});

@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController
    with WidgetsBindingObserver {
  Future<BiometricAuthStatus>? _authentication;

  @override
  AppLockStatus build() {
    WidgetsBinding.instance.addObserver(this);
    ref.listen<SettingsState>(settingsControllerProvider, (_, next) {
      next.whenOrNull(
        loaded: (settings) {
          if (!settings.biometricAuthEnabled &&
              state != AppLockStatus.unlocked) {
            state = AppLockStatus.unlocked;
          }
        },
      );
    });
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    return AppLockStatus.locked;
  }

  Future<BiometricAuthStatus> authenticate() {
    final activeAuthentication = _authentication;
    if (activeAuthentication != null) {
      return activeAuthentication;
    }

    final authentication = _authenticate();
    _authentication = authentication;
    return authentication.whenComplete(() {
      if (identical(_authentication, authentication)) {
        _authentication = null;
      }
    });
  }

  void lock() {
    final settings = ref.read(settingsControllerProvider);
    final biometricEnabled = settings.maybeWhen(
      loaded: (value) => value.biometricAuthEnabled,
      orElse: () => true,
    );
    if (!biometricEnabled) {
      state = AppLockStatus.unlocked;
      return;
    }

    if (state != AppLockStatus.locked) {
      state = AppLockStatus.locked;
    }
    unawaited(ref.read(secureClipboardServiceProvider).clear());
  }

  Future<BiometricAuthStatus> _authenticate() async {
    final settings = ref.read(settingsControllerProvider);
    final biometricEnabled = settings.maybeWhen(
      loaded: (value) => value.biometricAuthEnabled,
      orElse: () => false,
    );
    if (!biometricEnabled) {
      state = AppLockStatus.unlocked;
      return BiometricAuthStatus.disabled;
    }

    state = AppLockStatus.authenticating;
    final status = await ref.read(biometricAuthenticatorProvider)();
    if (status == BiometricAuthStatus.success) {
      state = AppLockStatus.unlocked;
    } else {
      state = AppLockStatus.locked;
    }
    return status;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      lock();
    }
  }
}
