import 'package:cipher/src/feature/account/screens/add_entity_screen.dart';
import 'package:cipher/src/feature/account/screens/view_account_screen.dart';
import 'package:cipher/src/feature/home/screens/home_screen.dart';
import 'package:cipher/src/feature/home/screens/how_to_screen.dart';
import 'package:cipher/src/feature/settings/screens/settings_screen.dart';
import 'package:cipher/src/feature/settings/utils/constants.dart';
import 'package:cipher/src/feature/splash/screens/splash_screen.dart';
import 'package:cipher/src/ui/error_screen.dart';
import 'package:flutter/material.dart' show Container;
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/splash",
  errorBuilder: (context, state) {
    return ErrorScreen();
  },
  routes: [
    GoRoute(
      path: "/",
      redirect: (context, state) {
        return "/splash";
      },
    ),
    GoRoute(
      path: "/splash",
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: "/home",
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(key: state.pageKey, child: HomeScreen());
      },
    ),
    GoRoute(
      path: "/howto",
      builder: (context, state) {
        return const HowToScreen();
      },
    ),
    GoRoute(
      path: "/auth",
      builder: (context, state) => Container(),
      routes: [
        GoRoute(
          path: "/add",
          builder: (context, state) {
            return const AddEntityScreen();
          },
        ),
        GoRoute(
          path: "/view",
          builder: (context, state) =>
              ViewAccountScreen(id: state.extra as String),
        ),
      ],
    ),
    GoRoute(
      path: "/settings",
      pageBuilder: (context, state) {
        return NoTransitionPage<void>(
          key: state.pageKey,
          child: SettingsScreen(),
        );
      },
    ),
    GoRoute(
      path: "/settings/update",
      builder: (context, state) {
        return UpdateSettingScreen(setting: state.extra as SettingsOption);
      },
    ),
  ],
);
