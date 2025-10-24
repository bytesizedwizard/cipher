import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Logo extends ConsumerWidget {
  // Whether to show the full logo or the compact logo.
  final bool full;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ThemeMode? mode;

  const Logo({
    super.key,
    this.full = false,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(settingsControllerProvider)
        .whenOrNull(loaded: (settings) => settings);

    final themeMode = settings?.themeMode ?? ThemeMode.system;

    if (!full) {
      return Image.asset(
        "assets/images/logo/logo_mini.png",
        fit: fit,
        width: width,
        height: height,
      );
    } else if (mode != null) {
      return Image.asset(
        "assets/images/logo/logo_full_${mode!.name}.png",
        fit: fit,
        width: width,
        height: height,
      );
    }

    return Image.asset(
      "assets/images/logo/logo_full_${themeMode.name}.png",
      fit: fit,
      width: width,
      height: height,
    );
  }
}
