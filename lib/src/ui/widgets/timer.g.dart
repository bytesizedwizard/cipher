// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timerNotifierHash() => r'2ad42b4306396a14502d10e14273d75d119592d1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$TimerNotifier extends BuildlessAutoDisposeNotifier<int> {
  late final int totalSeconds;

  int build(int totalSeconds);
}

/// See also [TimerNotifier].
@ProviderFor(TimerNotifier)
const timerNotifierProvider = TimerNotifierFamily();

/// See also [TimerNotifier].
class TimerNotifierFamily extends Family<int> {
  /// See also [TimerNotifier].
  const TimerNotifierFamily();

  /// See also [TimerNotifier].
  TimerNotifierProvider call(int totalSeconds) {
    return TimerNotifierProvider(totalSeconds);
  }

  @override
  TimerNotifierProvider getProviderOverride(
    covariant TimerNotifierProvider provider,
  ) {
    return call(provider.totalSeconds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timerNotifierProvider';
}

/// See also [TimerNotifier].
class TimerNotifierProvider
    extends AutoDisposeNotifierProviderImpl<TimerNotifier, int> {
  /// See also [TimerNotifier].
  TimerNotifierProvider(int totalSeconds)
    : this._internal(
        () => TimerNotifier()..totalSeconds = totalSeconds,
        from: timerNotifierProvider,
        name: r'timerNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timerNotifierHash,
        dependencies: TimerNotifierFamily._dependencies,
        allTransitiveDependencies:
            TimerNotifierFamily._allTransitiveDependencies,
        totalSeconds: totalSeconds,
      );

  TimerNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.totalSeconds,
  }) : super.internal();

  final int totalSeconds;

  @override
  int runNotifierBuild(covariant TimerNotifier notifier) {
    return notifier.build(totalSeconds);
  }

  @override
  Override overrideWith(TimerNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TimerNotifierProvider._internal(
        () => create()..totalSeconds = totalSeconds,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        totalSeconds: totalSeconds,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<TimerNotifier, int> createElement() {
    return _TimerNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimerNotifierProvider && other.totalSeconds == totalSeconds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, totalSeconds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimerNotifierRef on AutoDisposeNotifierProviderRef<int> {
  /// The parameter `totalSeconds` of this provider.
  int get totalSeconds;
}

class _TimerNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<TimerNotifier, int>
    with TimerNotifierRef {
  _TimerNotifierProviderElement(super.provider);

  @override
  int get totalSeconds => (origin as TimerNotifierProvider).totalSeconds;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
