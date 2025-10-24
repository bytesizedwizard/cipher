import 'package:cipher/src/feature/splash/state/splash.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transition_provider.g.dart';

@riverpod
class TransitionNotifier extends _$TransitionNotifier {
  @override
  SplashState build() => SplashState.initial();

  void start(Duration duration) {
    state = SplashState.loading();
    Future.delayed(duration, complete);
  }

  void complete() {
    state = SplashState.transition();
  }

  void error(String message) {
    state = SplashState.error(message);
  }

  void authRequired() {
    state = SplashState.authRequired();
  }
}
