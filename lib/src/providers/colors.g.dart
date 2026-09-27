// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'colors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(colorPalette)
final colorPaletteProvider = ColorPaletteProvider._();

final class ColorPaletteProvider
    extends $FunctionalProvider<ColorPalette, ColorPalette, ColorPalette>
    with $Provider<ColorPalette> {
  ColorPaletteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'colorPaletteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$colorPaletteHash();

  @$internal
  @override
  $ProviderElement<ColorPalette> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ColorPalette create(Ref ref) {
    return colorPalette(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ColorPalette value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ColorPalette>(value),
    );
  }
}

String _$colorPaletteHash() => r'f1fd8108abb8004bf8ef3310753eaf26395e367d';
