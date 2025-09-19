import 'package:flutter/material.dart'
    show ThemeMode, WidgetsBinding, Brightness;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void set(ThemeMode mode) {
    state = mode;
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
