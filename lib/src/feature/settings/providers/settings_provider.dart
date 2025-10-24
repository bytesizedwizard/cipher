import 'dart:convert';

import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart' show WidgetsBinding, Brightness;
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

enum BiometricAuthStatus {
  disabled,
  unknown,
  noBiometricHardware,
  success,
  failure,
  lockout,
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  final Settings defaultSettings = const Settings(
    themeMode: ThemeMode.system,
    clipboardTimeout: SettingsConstants.defaultClipboardTimeout,
    biometricAuthEnabled: SettingsConstants.defaultBiometricAuthEnabled,
  );

  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  Settings build() {
    // Load initial settings from persistent storage or set defaults
    loadSettings();

    return defaultSettings;
  }

  Future<void> loadSettings() async {
    final settingsEncoded = await _storageService.read(
      SettingsConstants.storageKey,
      StorageSource.sharedPreferences,
    );
    final settingsDecoded =
        jsonDecode(settingsEncoded ?? '{}') as Map<String, dynamic>;

    if (settingsDecoded.isNotEmpty) {
      state = Settings.fromJson(settingsDecoded);
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    saveSettings();
  }

  Future<void> updateClipboardTimeout(int timeout) async {
    state = state.copyWith(clipboardTimeout: timeout);
    saveSettings();
  }

  Future<void> updateBiometricAuthEnabled(bool isEnabled) async {
    state = state.copyWith(biometricAuthEnabled: isEnabled);
    saveSettings();
  }

  Future<BiometricAuthStatus> authenticate() async {
    try {
      if (!state.biometricAuthEnabled) {
        return BiometricAuthStatus.disabled;
      }

      LocalAuthentication localAuth = LocalAuthentication();
      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate via biometrics to proceed',
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
      );

      return isAuthenticated
          ? BiometricAuthStatus.success
          : BiometricAuthStatus.failure;
    } on LocalAuthException catch (e) {
      if (e.code == LocalAuthExceptionCode.noBiometricHardware) {
        return BiometricAuthStatus.noBiometricHardware;
      } else if (e.code == LocalAuthExceptionCode.temporaryLockout ||
          e.code == LocalAuthExceptionCode.biometricLockout) {
        return BiometricAuthStatus.lockout;
      } else {
        return BiometricAuthStatus.unknown;
      }
    }
  }

  Future<void> saveSettings() async {
    final settingsJson = state.toJson();
    final settingsEncoded = jsonEncode(settingsJson);

    await _storageService.write(
      SettingsConstants.storageKey,
      settingsEncoded,
      StorageSource.sharedPreferences,
    );
  }
}

extension Name on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.system:
        if (WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark) {
          return "dark";
        } else {
          return "light";
        }
      case ThemeMode.light:
        return "light";
      case ThemeMode.dark:
        return "dark";
    }
  }
}
