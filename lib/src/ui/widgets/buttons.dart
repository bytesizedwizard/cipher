import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A lightweight, themable icon-only button built on top of [IconButton].
///
/// This widget is a [ConsumerWidget] so it can read Riverpod providers when
/// needed (for example, to adapt styling to application state). It forwards
/// most of [IconButton]'s API while offering a concise constructor for common
/// icon-only actions.
///
/// Usage:
///
/// ```dart
/// FlatIconButton(
///   icon: const Icon(Icons.close),
///   onPressed: () => Navigator.of(context).pop(),
///   tooltip: 'Close',
/// )
/// ```
class FlatIconButton extends ConsumerWidget {
  /// Creates a [FlatIconButton].
  ///
  /// The [icon] parameter is required and represents the visual icon to show
  /// inside the button. All other parameters mirror [IconButton]'s options and
  /// are forwarded without modification.
  const FlatIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.iconColor,
    this.iconSize,
    this.alignment,
    this.autofocus = false,
    this.constraints,
    this.style,
    this.padding,
    this.tooltip,
    this.onLongPress,
    this.enableFeedback = true,
    this.splashRadius,
    this.mouseCursor,
    this.focusNode,
    this.semanticLabel,
  });

  /// Callback invoked when the button is pressed. If null, the button is
  /// considered disabled and will not react to input.
  final VoidCallback? onPressed;

  /// The icon widget to display inside the button. Accepts any widget (for
  /// example, [Icon], [Image], or an animated widget) to provide flexibility
  /// beyond a plain [Icon]. Prefer a semantic icon without extra padding so
  /// the surrounding [IconButton] controls layout.
  final Widget icon;

  /// Optional color to apply to the [icon]. If null, the theme/icon button
  /// defaults will determine the final color.
  final Color? iconColor;

  /// The icon size in logical pixels. When null, the icon's default size is
  /// used (usually 24.0).
  final double? iconSize;

  /// Alignment of the icon within the button's bounds.
  final AlignmentGeometry? alignment;

  /// Whether this button should be given input focus when it appears.
  final bool autofocus;

  /// Callback invoked when the button is long-pressed. Useful for alternate
  /// actions or context menus. If null, the long-press action is disabled.
  final VoidCallback? onLongPress;

  /// Whether to provide acoustic and haptic feedback for taps. Defaults to
  /// `true` to follow platform conventions.
  final bool enableFeedback;

  /// Radius of the splash for the tap feedback in logical pixels. If null,
  /// [IconButton]'s default splash radius is used.
  final double? splashRadius;

  /// Mouse cursor to use on hover (desktop/web). If null, the default cursor
  /// behavior is used.
  final MouseCursor? mouseCursor;

  /// Optional focus node to control focus programmatically.
  final FocusNode? focusNode;

  /// Optional constraints to control the button's overall size.
  final BoxConstraints? constraints;

  /// Optional [ButtonStyle] to customize the button's visual properties. Note
  /// that [IconButton] supports a subset of [ButtonStyle]; prefer direct
  /// properties or theming for typical use-cases.
  final ButtonStyle? style;

  /// Padding applied around the icon. Defaults to [IconButton]'s internal
  /// padding when null.
  final EdgeInsetsGeometry? padding;

  /// Accessibility tooltip. Shown on long-press and used by assistive
  /// technologies.
  final String? tooltip;

  /// An explicit semantic label for accessibility. If provided, this will be
  /// used by assistive technologies instead of relying on [tooltip].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget effectiveIcon = semanticLabel != null
        ? Semantics(label: semanticLabel, child: icon)
        : icon;

    return IconButton(
      onPressed: onPressed,
      icon: effectiveIcon,
      color: iconColor,
      alignment: alignment,
      autofocus: autofocus,
      onLongPress: onLongPress,
      enableFeedback: enableFeedback,
      constraints: constraints,
      style: style,
      padding: padding,
      iconSize: iconSize,
      splashRadius: splashRadius,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      tooltip: tooltip,
    );
  }
}
