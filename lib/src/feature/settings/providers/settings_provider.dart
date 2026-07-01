import 'dart:convert';

import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/account/services/storage_service.dart';
import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/widgets.dart' show WidgetsBinding, Brightness;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
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
  final _defaultSettings = Settings(
    themeMode: ThemeMode.system,
    clipboardTimeout: SettingsConstants.defaultClipboardTimeout,
    biometricAuthEnabled: SettingsConstants.defaultBiometricAuthEnabled,
  );
  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  SettingsState build() {
    return const SettingsState.initial();
  }

  Future<void> loadSettings() async {
    final settingsEncoded = await _storageService.read(
      SettingsConstants.storageKey,
      StorageSource.sharedPreferences,
    );
    final settingsDecoded =
        jsonDecode(settingsEncoded ?? '{}') as Map<String, dynamic>;

    if (settingsDecoded.isNotEmpty) {
      state = SettingsState.loaded(Settings.fromJson(settingsDecoded));
    } else {
      state = SettingsState.loaded(_defaultSettings);
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state.whenOrNull(
      loaded: (settings) {
        final updated = settings.copyWith(themeMode: mode);
        state = SettingsState.loaded(updated);
        saveSettings(updated);
      },
    );
  }

  Future<void> updateClipboardTimeout(int timeout) async {
    state.whenOrNull(
      loaded: (settings) {
        final updated = settings.copyWith(clipboardTimeout: timeout);
        state = SettingsState.loaded(updated);
        saveSettings(updated);
      },
    );
  }

  Future<void> updateBiometricAuthEnabled(bool isEnabled) async {
    state.whenOrNull(
      loaded: (settings) {
        final updated = settings.copyWith(biometricAuthEnabled: isEnabled);
        state = SettingsState.loaded(updated);
        saveSettings(updated);
      },
    );
  }

  Future<BiometricAuthStatus> authenticate({
    bool bypassIfDisabled = false,
  }) async {
    try {
      LocalAuthentication localAuth = LocalAuthentication();
      bool isAuthenticated = await localAuth.authenticate(
        localizedReason: 'Please authenticate via biometrics to proceed',
        persistAcrossBackgrounding: true,
        sensitiveTransaction: true,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: 'Authentication Required',
            signInHint: 'Please authenticate to proceed',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            localizedFallbackTitle: 'Please authenticate to proceed',
            cancelButton: 'Cancel',
          ),
        ],
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

  Future<void> acknowledgeBetaDisclaimer() async {
    state.whenOrNull(
      loaded: (settings) {
        final updated = settings.copyWith(doNotShowBetaDisclaimer: true);
        state = SettingsState.loaded(updated);
        saveSettings(updated);
      },
    );
  }

  Future<void> setSortField(AccountSortField field) async {
    state.whenOrNull(
      loaded: (settings) {
        final updated = settings.copyWith(sortField: field);
        state = SettingsState.loaded(updated);
        saveSettings(updated);
      },
    );
  }

  Future<Settings?> saveSettings(Settings settings) async {
    final settingsJson = settings.toJson();
    final settingsEncoded = jsonEncode(settingsJson);

    await _storageService.write(
      SettingsConstants.storageKey,
      settingsEncoded,
      StorageSource.sharedPreferences,
    );

    return null;
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
