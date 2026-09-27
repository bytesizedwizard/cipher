// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transition_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TransitionNotifier)
final transitionProvider = TransitionNotifierProvider._();

final class TransitionNotifierProvider
    extends $NotifierProvider<TransitionNotifier, SplashState> {
  TransitionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transitionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transitionNotifierHash();

  @$internal
  @override
  TransitionNotifier create() => TransitionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashState>(value),
    );
  }
}

String _$transitionNotifierHash() =>
    r'208e451fa002a2c8d9ed7fe6970c5ef4f11a88a8';

abstract class _$TransitionNotifier extends $Notifier<SplashState> {
  SplashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SplashState, SplashState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplashState, SplashState>,
              SplashState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
