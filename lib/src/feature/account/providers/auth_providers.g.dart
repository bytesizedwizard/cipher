// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authControllerHash() => r'346fea4de39875680fbc1ee256d51119672af111';

/// See also [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    NotifierProvider<AuthController, Map<String, AccountView>>.internal(
      AuthController.new,
      name: r'authControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthController = Notifier<Map<String, AccountView>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
