// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_storage_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(accountStorageService)
final accountStorageServiceProvider = AccountStorageServiceProvider._();

final class AccountStorageServiceProvider
    extends
        $FunctionalProvider<
          AccountStorageService,
          AccountStorageService,
          AccountStorageService
        >
    with $Provider<AccountStorageService> {
  AccountStorageServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountStorageServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountStorageServiceHash();

  @$internal
  @override
  $ProviderElement<AccountStorageService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccountStorageService create(Ref ref) {
    return accountStorageService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountStorageService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountStorageService>(value),
    );
  }
}

String _$accountStorageServiceHash() =>
    r'66226af65fb6752301a875931e7cc66ab7c25c04';
