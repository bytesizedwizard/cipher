import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/feature/splash/providers/transition_provider.dart';
import 'package:cipher/src/feature/splash/state/splash.dart';
import 'package:cipher/src/providers/app_lock_provider.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/logo_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref
        .watch(settingsControllerProvider)
        .whenOrNull(loaded: (settings) => settings);

    final palette = ref.watch(colorPaletteProvider);
    final textStyle = ref.watch(textStyleProvider);

    // Use useState to track if authentication has been attempted
    final hasInitialized = useState(false);

    // Initialize authentication flow only once
    useEffect(() {
      if (!hasInitialized.value && settings != null) {
        hasInitialized.value = true;

        // Use WidgetsBinding to avoid setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (settings.biometricAuthEnabled) {
            _performAuthentication(ref);
          } else {
            final transitionNotifier = ref.read(transitionProvider.notifier);
            transitionNotifier.start(const Duration(seconds: 2));
          }
        });
      }
      return null;
    }, [settings?.biometricAuthEnabled, hasInitialized.value]);

    // Listen for navigation transitions
    ref.listen(transitionProvider, (previous, next) {
      next.maybeWhen(
        transition: () {
          if (context.mounted) {
            context.go('/home');
          }
        },
        orElse: () {},
      );
    });

    final state = ref.watch(transitionProvider);

    return state.maybeWhen(
      initial: () => _buildLogo(),
      error: (message) => _buildError(message, ref, palette, textStyle),
      authRequired: () => _buildAuthRequired(ref),
      orElse: () => _buildLogo(),
    );
  }

  /// Performs biometric authentication with proper error handling
  Future<void> _performAuthentication(WidgetRef ref) async {
    final transitionNotifier = ref.read(transitionProvider.notifier);

    try {
      final status = await ref
          .read(appLockControllerProvider.notifier)
          .authenticate();

      switch (status) {
        case BiometricAuthStatus.success:
          transitionNotifier.start(const Duration(seconds: 1));
          break;
        case BiometricAuthStatus.failure:
        case BiometricAuthStatus.lockout:
          transitionNotifier.authRequired();
          break;
        case BiometricAuthStatus.disabled:
          transitionNotifier.start(const Duration(seconds: 2));
          break;
        case BiometricAuthStatus.noBiometricHardware:
        case BiometricAuthStatus.unknown:
          transitionNotifier.error(
            'Biometric authentication is unavailable. Check your device settings and try again.',
          );
      }
    } catch (error) {
      transitionNotifier.error('Authentication failed. Please try again.');
    }
  }

  Widget _buildLogo() {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 50),
            child: const Logo(full: true),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthRequired(WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(full: true),
            const Gap(20),
            const Text("Authentication Required"),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, _) {
                return SemanticElevatedButton(
                  semanticLabel: "Authenticate Button",
                  onPressed: () {
                    _performAuthentication(ref);
                  },
                  label: "Authenticate",
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    String message,
    WidgetRef ref,
    ColorPalette palette,
    Style textStyle,
  ) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: palette.error, size: 64),
                    const Gap(16),
                    Text(
                      'Authentication Error',
                      style: textStyle.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),
                    Text(
                      message,
                      style: textStyle.body,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(32),
                    SemanticElevatedButton(
                      semanticLabel: "Retry Authentication Button",
                      onPressed: () {
                        _performAuthentication(ref);
                      },
                      label: "Retry",
                    ),
                  ],
                ),
              ),
              const Logo(full: true, height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
