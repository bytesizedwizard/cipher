import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/cards.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/colors.dart';

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

class SemanticElevatedButton extends ConsumerWidget {
  const SemanticElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.semanticLabel,
    this.icon,
    this.buttonColor,
    this.labelColor,
    this.iconColor,
    this.iconSize = 24.0,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
    this.elevation = 2.0,
    this.border,
    this.disabledColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Widget? icon;
  final Color? buttonColor;
  final Color? disabledColor;
  final Color? labelColor;
  final Color? iconColor;
  final double iconSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderSide? border;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? palette.accent,
          foregroundColor: labelColor ?? palette.primary,
          disabledBackgroundColor: disabledColor ?? palette.border,
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: border ?? BorderSide.none,
          ),
          minimumSize: const Size.fromHeight(48),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              IconTheme(
                data: IconThemeData(
                  color: iconColor ?? palette.primary,
                  size: iconSize,
                ),
                child: icon!,
              ),
            if (icon != null) const SizedBox(width: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: labelColor ?? palette.primary,
              ),
            ),
            if (icon != null)
              const Opacity(
                opacity: 0,
                child: Icon(Icons.close),
              ), // balances layout
          ],
        ),
      ),
    );
  }
}

class SemanticTextButton extends ConsumerWidget {
  const SemanticTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.semanticLabel,
    this.labelColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    this.borderRadius = 8.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final Color? labelColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: labelColor ?? palette.accent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: const Size.fromHeight(36),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyles.body.copyWith(
            color: labelColor ?? palette.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Direction in which radio buttons are laid out.
/// Horizontal: left to right.
/// Vertical: top to bottom.
enum RadioButtonDirection { horizontal, vertical }

class RadioButtonOption<T> {
  final T value;
  final String label;

  RadioButtonOption({required this.value, required this.label});
}

class SemanticRadioButtonGroup<T> extends ConsumerWidget {
  const SemanticRadioButtonGroup({
    super.key,
    required this.options,
    required this.groupValue,
    required this.onChanged,
    this.semanticLabel,
    this.padding = const EdgeInsets.symmetric(horizontal: 0.0),
  });

  final List<RadioButtonOption> options;
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = ref.watch(textStyleProvider);

    return Padding(
      padding: padding,
      child: SemanticCard(
        padding: const EdgeInsets.all(0.0),
        child: Semantics(
          label: semanticLabel,
          child: RadioGroup<T>(
            groupValue: groupValue,
            onChanged: onChanged,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: options.map((option) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      leadingAndTrailingTextStyle: textStyles.heading3.copyWith(
                        fontSize: 21,
                      ),
                      leading: Radio<T>(value: option.value),
                      titleTextStyle: textStyles.heading3,
                      title: Text(
                        option.label.toString(),
                        style: textStyles.body,
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      style: ListTileStyle.list,
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    const Divider(height: 0),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class SemanticToggleButton extends ConsumerWidget {
  const SemanticToggleButton({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.padding = const EdgeInsets.symmetric(horizontal: 25.0),
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = ref.watch(textStyleProvider);

    return Padding(
      padding: padding,
      child: SemanticCard(
        padding: const EdgeInsets.all(0.0),
        child: Semantics(
          label: semanticLabel,
          child: SwitchListTile(
            title: Text(label, style: textStyles.heading3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
