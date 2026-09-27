// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'styles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(textStyle)
final textStyleProvider = TextStyleProvider._();

final class TextStyleProvider extends $FunctionalProvider<Style, Style, Style>
    with $Provider<Style> {
  TextStyleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textStyleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textStyleHash();

  @$internal
  @override
  $ProviderElement<Style> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Style create(Ref ref) {
    return textStyle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Style value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Style>(value),
    );
  }
}

String _$textStyleHash() => r'305ad53ef0257fe73861d9d92d71661ac263179e';
