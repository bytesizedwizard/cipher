import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: SensitiveContent(
        sensitivity: ContentSensitivity.sensitive,
        child: Consumer(
          builder: (context, ref, _) {
            final settingsNotifier = ref.watch(
              settingsControllerProvider.notifier,
            );

            settingsNotifier.loadSettings();

            return const CipherApp();
          },
        ),
      ),
    ),
  );
}

class CipherApp extends ConsumerWidget {
  const CipherApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final settings = ref.watch(settingsControllerProvider);

    return settings.maybeWhen(
      orElse: () => Container(),
      loaded: (settings) {
        return MaterialApp.router(
          theme: ThemeData(
            scaffoldBackgroundColor: palette.primary,
            appBarTheme: AppBarTheme(
              backgroundColor: palette.primary,
              foregroundColor: palette.font,
              elevation: 2,
              centerTitle: false,
              surfaceTintColor: palette.accent,
            ),
            buttonTheme: ButtonThemeData(buttonColor: palette.accent),
            dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
            cardColor: palette.primary,
            shadowColor: palette.accent.withValues(alpha: 0.25),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: palette.primary,
              selectedItemColor: palette.accent,
              unselectedItemColor: palette.border,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
            ),
            dividerColor: palette.border,
            bottomAppBarTheme: BottomAppBarThemeData(
              color: palette.primary,
              elevation: 2,
              surfaceTintColor: palette.accent,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: palette.accent,
              foregroundColor: palette.primary,
            ),
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.all(palette.accent),
            ),
            toggleButtonsTheme: ToggleButtonsThemeData(
              color: palette.font,
              selectedColor: palette.primary,
              fillColor: palette.accent,
              borderColor: palette.border,
              selectedBorderColor: palette.accent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return palette.accent;
                }
                return palette.border;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return palette.success;
                }
                return palette.border.withValues(alpha: 0.5);
              }),
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: palette.accent,
              contentTextStyle: TextStyle(color: palette.primary),
              actionTextColor: palette.primary,
              behavior: SnackBarBehavior.floating,
            ),
          ),
          themeMode: settings.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
