import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/platform.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/app_bar.dart';
import 'package:cipher/src/ui/widgets/bottom_bars.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/cards.dart';
import 'package:cipher/src/ui/widgets/logo_type.dart';
import 'package:cipher/src/ui/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);

    return Scaffold(
      appBar: BaseAppBar(
        toolbarHeight: 70,
        titleSpacing: 25,
        title: const Text("Settings"),
        elevation: 0,
      ),
      bottomNavigationBar: const BottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildSettingsSection(
                title: "Appearance",
                children: [
                  _buildSettingsTile(
                    leading: Icons.light_mode,
                    title: const Text("Theme"),
                    onTap: () {
                      context.push(
                        "/settings/update",
                        extra: SettingsOption.theme,
                      );
                    },
                    palette: palette,
                    textStyles: textStyles,
                  ),
                ],
                textStyles: textStyles,
                palette: palette,
              ),
              const Gap(20),
              ..._buildSettingsSection(
                title: "Privacy & Security",
                children: [
                  _buildSettingsTile(
                    leading: Icons.fingerprint,
                    title: const Text("Biometric Authentication"),
                    onTap: () {
                      context.push(
                        "/settings/update",
                        extra: SettingsOption.biometricAuth,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    palette: palette,
                    textStyles: textStyles,
                  ),
                  const Divider(height: 0),
                  _buildSettingsTile(
                    leading: Icons.timer,
                    title: const Text("Clipboard Timeout"),
                    onTap: () {
                      context.push(
                        "/settings/update",
                        extra: SettingsOption.clipboardTimeout,
                      );
                    },
                    palette: palette,
                    textStyles: textStyles,
                  ),
                  const Divider(height: 0),
                  _buildSettingsTile(
                    leading: Icons.security,
                    title: const Text("Recovery Codes"),
                    onTap: () {
                      context.push(
                        "/settings/update",
                        extra: SettingsOption.recoveryCodes,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    palette: palette,
                    textStyles: textStyles,
                    isComingSoon: true,
                  ),
                ],
                textStyles: textStyles,
                palette: palette,
              ),
              const Gap(20),
              ..._buildSettingsSection(
                title: "Backup & Recovery",
                children: [
                  _buildSettingsTile(
                    leading: Icons.import_export,
                    title: const Text("Import / Export Data"),
                    onTap: () {
                      context.push(
                        "/settings/update",
                        extra: SettingsOption.importData,
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    palette: palette,
                    textStyles: textStyles,
                    isComingSoon: true,
                  ),
                  // const Divider(height: 0),
                  // _buildSettingsTile(
                  //   leading: Icons.upload,
                  //   title: const Text("Export Data"),
                  //   onTap: () {
                  //     context.push(
                  //       "/settings/update",
                  //       extra: SettingsOption.exportData,
                  //     );
                  //   },
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //       bottomLeft: Radius.circular(8.0),
                  //       bottomRight: Radius.circular(8.0),
                  //     ),
                  //   ),
                  //   palette: palette,
                  //   textStyles: textStyles,
                  //   isComingSoon: true,
                  // ),
                ],
                textStyles: textStyles,
                palette: palette,
              ),
              const Gap(20),
              ..._buildSettingsSection(
                title: "Privacy & Usage",
                textStyles: textStyles,
                palette: palette,
                children: [
                  _buildSettingsTile(
                    leading: Symbols.contract,
                    title: const Text("Terms of Use"),
                    onTap: () async {
                      if (await canLaunchUrlString(
                        SettingsConstants.termsOfServiceUrl,
                      )) {
                        launchUrlString(SettingsConstants.termsOfServiceUrl);
                      }
                    },
                    textStyles: textStyles,
                    palette: palette,
                  ),
                  const Divider(height: 0),
                  _buildSettingsTile(
                    leading: Symbols.encrypted,
                    title: const Text("Privacy Policy"),
                    onTap: () async {
                      if (await canLaunchUrlString(
                        SettingsConstants.privacyPolicyUrl,
                      )) {
                        launchUrlString(SettingsConstants.privacyPolicyUrl);
                      }
                    },
                    textStyles: textStyles,
                    palette: palette,
                  ),
                ],
              ),
              const Gap(40),
              ..._buildAboutSection(
                context,
                textStyles: textStyles,
                palette: palette,
              ),
              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsSection({
    required String title,
    required List<Widget> children,
    required Style textStyles,
    required ColorPalette palette,
  }) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 4.0),
        child: Text(title, style: textStyles.heading3),
      ),
      const Gap(5),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SemanticCard(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ];
  }

  Widget _buildSettingsTile({
    required IconData leading,
    required Widget title,
    required VoidCallback onTap,
    required Style textStyles,
    required ColorPalette palette,
    ShapeBorder? shape,
    bool isExperimental = false,
    bool isComingSoon = false,
  }) {
    return ListTile(
      leadingAndTrailingTextStyle: textStyles.heading3.copyWith(fontSize: 21),
      leading: Icon(leading, size: 21, color: palette.accent),
      title: title,
      titleTextStyle: textStyles.heading3,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      style: ListTileStyle.list,
      dense: true,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      onTap: isComingSoon ? null : onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isExperimental)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  "EXPERIMENTAL",
                  style: textStyles.label.copyWith(
                    color: palette.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else if (isComingSoon)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  "COMING SOON",
                  style: textStyles.label.copyWith(
                    color: palette.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (!isComingSoon) const Icon(Icons.chevron_right, size: 21),
        ],
      ),
    );
  }

  List<Widget> _buildAboutSection(
    BuildContext context, {
    required Style textStyles,
    required ColorPalette palette,
  }) {
    return [
      Logo(height: 20, full: true),
      const Gap(15),
      Consumer(
        builder: (context, ref, child) {
          final packageInfo = ref.watch(platformInfoProvider);

          return packageInfo.maybeWhen(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text(
              "Error loading version information: $error",
              textAlign: TextAlign.center,
              style: textStyles.body.copyWith(
                color: palette.accent.withValues(alpha: 0.5),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
            data: (data) => Text(
              "Version ${data.version} (${data.buildNumber})",
              textAlign: TextAlign.center,
              style: textStyles.body.copyWith(
                color: palette.accent.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
      const Gap(5),
      Consumer(
        builder: (context, ref, _) {
          final packageInfo = ref.watch(platformInfoProvider);
          return packageInfo.maybeWhen(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
            data: (data) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: SemanticTextButton(
                  label: "Open Source Licenses",
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationVersion:
                          "Version ${data.version} (${data.buildNumber})",
                      applicationIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: const Logo(height: 40, full: true),
                      ),
                    );
                  },
                  semanticLabel: "Open Source Licenses button",
                ),
              );
            },
          );
        },
      ),
    ];
  }
}

class UpdateSettingScreen extends ConsumerWidget {
  final SettingsOption setting;

  const UpdateSettingScreen({super.key, required this.setting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);

    return Scaffold(
      appBar: BaseAppBar(
        titleSpacing: 0,
        title: Text(SettingsConstants.settingsTitles[setting]!),
        elevation: 0,
        titleTextStyle: textStyles.heading2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildSettingsView(context, palette, textStyles),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSettingsView(
    BuildContext context,
    ColorPalette palette,
    Style textStyles,
  ) {
    switch (setting) {
      case SettingsOption.theme:
        return [
          ListTile(
            title: Text("Select Theme", style: textStyles.heading3),
            subtitle: Text(
              "Choose between light, dark, or system default theme.",
              style: textStyles.body,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
          ),
          const Gap(12),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(settingsControllerProvider);

              return settings.maybeWhen(
                orElse: () => LinearProgressIndicator(),
                loaded: (settings) {
                  return SemanticRadioButtonGroup(
                    options: <RadioButtonOption>[
                      RadioButtonOption(value: ThemeMode.light, label: "Light"),
                      RadioButtonOption(value: ThemeMode.dark, label: "Dark"),
                      RadioButtonOption(
                        value: ThemeMode.system,
                        label: "System",
                      ),
                    ],
                    groupValue: settings.themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .updateThemeMode(value);
                      }
                    },
                  );
                },
              );
            },
          ),
        ];
      case SettingsOption.biometricAuth:
        return [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "Enable or disable biometric authentication for added security.",
              style: textStyles.body,
            ),
          ),
          const Gap(20),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(settingsControllerProvider);
              final settingsNotifier = ref.read(
                settingsControllerProvider.notifier,
              );

              return settings.maybeWhen(
                orElse: () => LinearProgressIndicator(),
                loaded: (settings) {
                  return SemanticToggleButton(
                    label: settings.biometricAuthEnabled
                        ? "Enabled"
                        : "Disabled",
                    value: settings.biometricAuthEnabled,
                    onChanged: (value) {
                      if (value) {
                        settingsNotifier.authenticate(bypassIfDisabled: true).then((
                          status,
                        ) {
                          if (status == BiometricAuthStatus.success) {
                            settingsNotifier.updateBiometricAuthEnabled(true);
                          } else {
                            String message;

                            switch (status) {
                              case BiometricAuthStatus.disabled:
                                message =
                                    "Biometric authentication is disabled in device settings.";
                                break;
                              case BiometricAuthStatus.unknown:
                                message =
                                    "Biometric authentication failed due to an unknown error.";
                                break;
                              case BiometricAuthStatus.noBiometricHardware:
                                message =
                                    "No biometric hardware found on this device.";
                                break;
                              case BiometricAuthStatus.failure:
                                message = "Biometric authentication failed.";
                                break;
                              case BiometricAuthStatus.lockout:
                                message =
                                    "Biometric authentication is temporarily locked out. Please try again later.";
                                break;
                              case BiometricAuthStatus.success:
                                ref
                                    .read(settingsControllerProvider.notifier)
                                    .updateBiometricAuthEnabled(value);
                                message = "Biometric authentication succeeded.";
                                break;
                            }

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        });

                        return;
                      } else {
                        ref
                            .read(settingsControllerProvider.notifier)
                            .updateBiometricAuthEnabled(value);
                      }
                    },
                  );
                },
              );
            },
          ),
        ];
      case SettingsOption.clipboardTimeout:
        return [
          ListTile(
            subtitle: Text(
              "Any copied codes will be cleared from clipboard after this duration (in seconds).",
              style: textStyles.body,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 25.0),
          ),
          const Gap(12),
          Consumer(
            builder: (context, ref, _) {
              final settingsProvider = ref.watch(settingsControllerProvider);

              return settingsProvider.maybeWhen(
                orElse: () => LinearProgressIndicator(),
                loaded: (settings) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: CustomTextFormField(
                      hintText: "Timeout in seconds",
                      textInputType: TextInputType.number,
                      initialValue: Duration(
                        milliseconds: settings.clipboardTimeout,
                      ).inSeconds.toString(),
                      onChanged: (value) {
                        final intValue = int.tryParse(value) ?? 0;

                        if (intValue > 0) {
                          ref
                              .read(settingsControllerProvider.notifier)
                              .updateClipboardTimeout(
                                Duration(seconds: intValue).inMilliseconds,
                              );
                        }
                      },
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(
                          Icons.timer,
                          size: 21,
                          color: palette.accent,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ];
      case SettingsOption.recoveryCodes:
      case SettingsOption.importData:
      case SettingsOption.exportData:
        return [];
      default:
        return [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              "This setting is not yet implemented.",
              style: textStyles.body,
            ),
          ),
        ];
    }
  }
}
