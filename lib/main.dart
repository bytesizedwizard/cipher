import 'dart:async';

import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb ||
      (defaultTargetPlatform != TargetPlatform.android &&
          defaultTargetPlatform != TargetPlatform.iOS)) {
    runApp(const UnsupportedPlatformApp());
    return;
  }

  runApp(ProviderScope(child: const CipherBootstrap()));
}

class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Cipher currently supports Android and iOS only.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class CipherBootstrap extends ConsumerStatefulWidget {
  const CipherBootstrap({super.key});

  @override
  ConsumerState<CipherBootstrap> createState() => _CipherBootstrapState();
}

class _CipherBootstrapState extends ConsumerState<CipherBootstrap> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(settingsControllerProvider.notifier).loadSettings());
  }

  @override
  Widget build(BuildContext context) => const CipherApp();
}

class CipherApp extends ConsumerWidget {
  const CipherApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final settings = ref.watch(settingsControllerProvider);
    final appRouter = ref.watch(routerProvider);

    return settings.maybeWhen(
      orElse: () {
        final ThemeMode themeMode =
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: palette.primary),
          themeMode: themeMode,
          builder: (context, child) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: palette.accent,
                ),
              ),
            );
          },
        );
      },
      loaded: (settings) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
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
            iconButtonTheme: IconButtonThemeData(
              style: IconButton.styleFrom(foregroundColor: palette.font),
            ),
          ),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
