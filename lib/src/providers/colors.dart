import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart'
    show Color, WidgetsBinding, Brightness, ThemeMode;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'colors.g.dart';

abstract class ColorPalette {
  Color get primary;
  Color get accent;
  Color get font;
  Color get border;
  Color get error;
  Color get warning;
  Color get success;
}

class LightPalette implements ColorPalette {
  @override
  Color get primary => const Color.fromARGB(255, 251, 255, 254);

  @override
  Color get accent => const Color.fromARGB(255, 0, 25, 16);

  @override
  Color get font => accent;

  @override
  Color get border => const Color(0xFFE0E0E0);

  @override
  Color get error => const Color(0xFFB00020);

  @override
  Color get warning => const Color(0xFFFFA000);

  @override
  Color get success => const Color.fromARGB(255, 0, 87, 55);
}

class DarkPalette implements ColorPalette {
  @override
  Color get primary => const Color.fromARGB(255, 0, 8, 5);

  @override
  Color get accent => const Color.fromARGB(255, 243, 255, 251);

  @override
  Color get font => const Color(0xFFFFFFFF);

  @override
  Color get border => const Color.fromARGB(255, 82, 82, 82);

  @override
  Color get error => const Color(0xFFCF6679);

  @override
  Color get warning => const Color(0xFFFFA000);

  @override
  Color get success => const Color.fromARGB(255, 10, 192, 125);
}

@Riverpod(keepAlive: true)
ColorPalette colorPalette(Ref ref) {
  final settings = ref
      .watch(settingsControllerProvider)
      .maybeWhen(loaded: (settings) => settings, orElse: () => null);
  final themeMode = settings?.themeMode;

  final dark = DarkPalette();
  final light = LightPalette();

  return switch (themeMode) {
    ThemeMode.light => light,
    ThemeMode.dark => dark,
    ThemeMode.system =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? dark
          : light,
    null => light,
  };
}
