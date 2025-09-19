import 'package:cipher/src/feature/auth/screens/add_entity_screen.dart';
import 'package:cipher/src/feature/home/screens/home_screen.dart';
import 'package:cipher/src/feature/settings/screens/settings_screen.dart';
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
      path: "/auth",
      builder: (context, state) => Container(),
      routes: [
        GoRoute(
          path: "/add",
          builder: (context, state) {
            return const AddEntityScreen();
          },
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
  ],
);
