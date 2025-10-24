import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SemanticCard extends ConsumerWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  final double borderRadius;
  final double elevation;

  final Color? color;
  final BorderSide? border;

  const SemanticCard({
    super.key,
    this.semanticLabel,
    this.child,
    this.margin,
    this.borderRadius = 10,
    this.elevation = 0,
    this.color,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Card(
        elevation: elevation,
        shadowColor: palette.accent.withValues(alpha: 0.1),
        borderOnForeground: true,
        color: color ?? palette.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: border ?? BorderSide(color: palette.border, width: 1),
        ),
        key: key,
        margin: margin ?? EdgeInsets.zero,
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      ),
    );
  }
}
