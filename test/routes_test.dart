import 'package:cipher/src/providers/app_lock_provider.dart';
import 'package:cipher/src/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('redirects protected routes to the splash screen while locked', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appLockControllerProvider.overrideWithValue(AppLockStatus.locked),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.go('/home');
    await tester.pump();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/splash');
  });

  testWidgets('allows protected routes after the app is unlocked', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        appLockControllerProvider.overrideWithValue(AppLockStatus.unlocked),
      ],
    );
    addTearDown(container.dispose);

    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.go('/home');
    await tester.pump();

    expect(router.routerDelegate.currentConfiguration.uri.path, '/home');
  });
}
