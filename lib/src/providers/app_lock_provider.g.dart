// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppLockController)
final appLockControllerProvider = AppLockControllerProvider._();

final class AppLockControllerProvider
    extends $NotifierProvider<AppLockController, AppLockStatus> {
  AppLockControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockControllerHash();

  @$internal
  @override
  AppLockController create() => AppLockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLockStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLockStatus>(value),
    );
  }
}

String _$appLockControllerHash() => r'0632d7f2a66ffd725af57728dda099402cd05ff0';

abstract class _$AppLockController extends $Notifier<AppLockStatus> {
  AppLockStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLockStatus, AppLockStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLockStatus, AppLockStatus>,
              AppLockStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
