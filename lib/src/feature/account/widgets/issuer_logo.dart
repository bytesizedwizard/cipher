import 'package:cipher/src/feature/account/utils/issuer_logos.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Displays a branded logo for a service issuer.
///
/// Shows the matching SVG logo from bundled assets when available.
/// Falls back to a [CircleAvatar] with the first letter of the issuer
/// when no logo is found, or a generic key icon when issuer is empty.
class IssuerLogo extends ConsumerWidget {
  /// The issuer name to look up (e.g., "Google", "GitHub").
  final String issuer;

  /// Diameter of the logo circle. Default 40px for list items.
  final double size;

  /// Whether to render as a circle (true) or rounded-rect (false).
  /// Circular fallbacks ([CircleAvatar]) are always round; SVG logos
  /// use rounded-rect to avoid clipping non-square artwork.
  final bool circular;

  const IssuerLogo({
    super.key,
    required this.issuer,
    this.size = 40,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final assetPath = resolveIssuerLogo(issuer);

    if (assetPath != null) {
      return _svgLogo(assetPath);
    }

    if (issuer.trim().isEmpty) {
      return _genericFallback(palette);
    }

    return _initialFallback(issuer, palette);
  }

  Widget _svgLogo(String path) {
    final widget = SvgPicture.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => _loadingPlaceholder(),
    );

    if (circular) {
      return ClipOval(child: widget);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: widget,
    );
  }

  Widget _initialFallback(String issuer, ColorPalette palette) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: palette.accent.withValues(alpha: 0.1),
      child: Text(
        issuer.trim()[0].toUpperCase(),
        style: TextStyle(
          color: palette.accent,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _genericFallback(ColorPalette palette) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: palette.accent.withValues(alpha: 0.1),
      child: Icon(
        Icons.key,
        color: palette.accent,
        size: size * 0.5,
      ),
    );
  }

  Widget _loadingPlaceholder() {
    return SizedBox(width: size, height: size);
  }
}