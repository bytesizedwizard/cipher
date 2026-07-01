abstract class SettingsConstants {
  static const int defaultClipboardTimeout = 30000; // in milliseconds
  static const bool defaultBiometricAuthEnabled = false;

  static const String storageKey = "settings";
  static const settingsTitles = {
    SettingsOption.theme: "Theme",
    SettingsOption.biometricAuth: "Biometric Authentication",
    SettingsOption.clipboardTimeout: "Clipboard Timeout",
    SettingsOption.importData: "Import Data",
    SettingsOption.exportData: "Export Data",
    SettingsOption.openSourceLicenses: "Open Source Licenses",
  };

  static const String privacyPolicyUrl =
      "https://bytesizedwizard.dev/cipher/privacy";
  static const String termsOfServiceUrl =
      "https://bytesizedwizard.dev/cipher/terms";
}

enum SettingsOption {
  theme,
  biometricAuth,
  clipboardTimeout,
  recoveryCodes,
  importData,
  exportData,
  openSourceLicenses,
}
