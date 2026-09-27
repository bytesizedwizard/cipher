// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'totp_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(totpService)
final totpServiceProvider = TotpServiceProvider._();

final class TotpServiceProvider
    extends $FunctionalProvider<TotpService, TotpService, TotpService>
    with $Provider<TotpService> {
  TotpServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totpServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totpServiceHash();

  @$internal
  @override
  $ProviderElement<TotpService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TotpService create(Ref ref) {
    return totpService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TotpService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TotpService>(value),
    );
  }
}

String _$totpServiceHash() => r'3fb1c27d87f5d65e201a6b431ab410297e967dd1';
