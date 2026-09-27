import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;
  const factory SettingsState.loading() = _Loading;
  const factory SettingsState.loaded(Settings settings) = _Loaded;
  const factory SettingsState.error(String message) = _Error;
}

@freezed
@JsonSerializable()
class Settings with _$Settings {
  @override
  @JsonKey(name: 'theme_mode', defaultValue: ThemeMode.system)
  final ThemeMode themeMode;

  @override
  @JsonKey(
    name: 'clipboard_timeout',
    defaultValue: SettingsConstants.defaultClipboardTimeout,
  )
  final int clipboardTimeout; // in milliseconds

  @override
  @JsonKey(
    name: 'biometric_auth_enabled',
    defaultValue: SettingsConstants.defaultBiometricAuthEnabled,
  )
  final bool biometricAuthEnabled;

  @override
  @JsonKey(name: 'do_not_show_beta_disclaimer', defaultValue: false)
  final bool doNotShowBetaDisclaimer;

  @override
  @JsonKey(name: 'sort_field', defaultValue: AccountSortField.dateAddedNewest)
  final AccountSortField sortField;

  const Settings({
    required this.themeMode,
    required this.clipboardTimeout,
    required this.biometricAuthEnabled,
    this.doNotShowBetaDisclaimer = false,
    this.sortField = AccountSortField.dateAddedNewest,
  });

  factory Settings.fromJson(Map<String, Object?> json) =>
      _$SettingsFromJson(json);

  Map<String, Object?> toJson() => _$SettingsToJson(this);
}

extension SettingsX on Settings {
  bool get isDarkMode => themeMode == ThemeMode.dark;
}
