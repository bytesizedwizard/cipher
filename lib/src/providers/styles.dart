import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'styles.g.dart';

class Style {
  ColorPalette palette;

  Style._({required this.palette});

  TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 21,
    color: palette.font,
    fontWeight: FontWeight.bold,
  );

  TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: palette.font,
  );

  TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: palette.font,
  );

  TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: palette.font,
    letterSpacing: 0,
  );

  TextStyle get label => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: palette.font,
  );
}

@Riverpod(keepAlive: true)
Style textStyle(Ref ref) {
  final palette = ref.watch(colorPaletteProvider);
  return Style._(palette: palette);
}
