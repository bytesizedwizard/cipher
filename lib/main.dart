import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/theme.dart';
import 'package:cipher/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(ProviderScope(child: const CipherApp()));
}

class CipherApp extends ConsumerWidget {
  const CipherApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final themeMode = ref.watch(themeNotifierProvider);

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
      ),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
