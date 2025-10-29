// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
  themeMode:
      $enumDecodeNullable(_$ThemeModeEnumMap, json['theme_mode']) ??
      ThemeMode.system,
  clipboardTimeout: (json['clipboard_timeout'] as num?)?.toInt() ?? 30000,
  biometricAuthEnabled: json['biometric_auth_enabled'] as bool? ?? false,
  doNotShowBetaDisclaimer:
      json['do_not_show_beta_disclaimer'] as bool? ?? false,
);

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
  'theme_mode': _$ThemeModeEnumMap[instance.themeMode]!,
  'clipboard_timeout': instance.clipboardTimeout,
  'biometric_auth_enabled': instance.biometricAuthEnabled,
  'do_not_show_beta_disclaimer': instance.doNotShowBetaDisclaimer,
};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
