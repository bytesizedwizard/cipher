import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash.freezed.dart';

@freezed
abstract class SplashState with _$SplashState {
  const SplashState._();

  const factory SplashState.initial() = _Initial;
  const factory SplashState.loading() = _Loading;
  const factory SplashState.transition() = _Transition;
  const factory SplashState.error(String message) = _Error;
  const factory SplashState.authRequired() = _AuthRequired;
}
