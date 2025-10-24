import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_models.freezed.dart';
part 'settings_models.g.dart';

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

  const Settings({
    required this.themeMode,
    required this.clipboardTimeout,
    required this.biometricAuthEnabled,
  });

  factory Settings.fromJson(Map<String, Object?> json) =>
      _$SettingsFromJson(json);

  Map<String, Object?> toJson() => _$SettingsToJson(this);
}

extension SettingsX on Settings {
  bool get isDarkMode => themeMode == ThemeMode.dark;
}
