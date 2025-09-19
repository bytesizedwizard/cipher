import 'package:cipher/src/feature/splash/providers/transition_provider.dart';
import 'package:cipher/src/feature/splash/state/splash.dart';
import 'package:cipher/src/ui/widgets/logo_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transitionProvider = ref.watch(transitionNotifierProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      transitionProvider.start(Duration(seconds: 2));
    });

    ref.listen(transitionNotifierProvider, (previous, next) {
      next.when(
        initial: () {},
        loading: () {},
        transition: () {
          context.go("/home");
        },
        error: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $message')));
        },
      );
    });

    return _buildLogo();
  }

  Widget _buildLogo() {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 50),
            child: Logo(full: true),
          ),
        ),
      ),
    );
  }
}
