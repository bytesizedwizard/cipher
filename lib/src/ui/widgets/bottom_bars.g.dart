// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bottom_bars.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BottomBarIndexNotifier)
final bottomBarIndexProvider = BottomBarIndexNotifierProvider._();

final class BottomBarIndexNotifierProvider
    extends $NotifierProvider<BottomBarIndexNotifier, int> {
  BottomBarIndexNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bottomBarIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bottomBarIndexNotifierHash();

  @$internal
  @override
  BottomBarIndexNotifier create() => BottomBarIndexNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$bottomBarIndexNotifierHash() =>
    r'ee7ff513e3a9d38ad03df346f48bb4f5b23cfefc';

abstract class _$BottomBarIndexNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
