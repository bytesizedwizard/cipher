import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A customizable app bar widget that wraps Flutter's AppBar with consistent theming and behavior.
///
/// This widget provides a standardized app bar implementation across the application
/// with integration to the app's color palette and styling system. It extends [ConsumerWidget]
/// and implements [PreferredSizeWidget] to work as a proper app bar.
///
/// The base app bar includes:
/// - Automatic theme integration with color palette
/// - Customizable title, leading, and action widgets
/// - Consistent elevation and styling
/// - Support for all standard AppBar features
/// - Optional automatic back button handling
///
/// Example usage:
/// ```dart
/// Scaffold(
///   appBar: BaseAppBar(
///     title: 'Home',
///     actions: [
///       IconButton(
///         icon: Icon(Icons.settings),
///         onPressed: () => context.push('/settings'),
///       ),
///     ],
///   ),
///   body: YourContent(),
/// )
/// ```
///
/// See also:
/// - [AppBar], the underlying Material Design widget
/// - [PreferredSizeWidget], the interface this widget implements
class BaseAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.titleTextStyle,
    this.toolbarHeight,
    this.leadingWidth,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.scrolledUnderElevation,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.forceMaterialTransparency = false,
    this.clipBehavior,
    this.bottom,
  });

  /// The primary widget displayed in the app bar.
  ///
  /// Typically a [Text] widget that contains a description of the current
  /// contents of the app. If [title] is a [String], it will be automatically
  /// wrapped in a [Text] widget with appropriate styling.
  final Widget? title;

  /// A widget to display before the [title].
  ///
  /// Typically an [IconButton] or [BackButton] that allows the user to navigate
  /// to the previous screen. If null and [automaticallyImplyLeading] is true,
  /// an appropriate button will be automatically created.
  final Widget? leading;

  /// A list of widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the last action.
  final List<Widget>? actions;

  /// Controls whether we should try to imply the leading widget if null.
  ///
  /// If true and [leading] is null, automatically try to deduce what the leading
  /// widget should be (typically a back button or drawer menu icon).
  final bool automaticallyImplyLeading;

  /// Whether the title should be centered.
  ///
  /// If null, then the value is adapted from the current [ThemeData.platform].
  final bool? centerTitle;

  /// The material elevation of the app bar.
  ///
  /// If null, uses the theme's default app bar elevation.
  final double? elevation;

  /// The fill color to use for the app bar's material.
  ///
  /// If null, uses the color from the app's color palette.
  final Color? backgroundColor;

  /// The default color for [Text] and [Icon]s within the app bar.
  ///
  /// If null, uses the appropriate contrast color for the background.
  final Color? foregroundColor;

  /// The color of the shadow below the app bar.
  ///
  /// If null, uses the theme's shadow color.
  final Color? shadowColor;

  /// The color of the surface tint overlay applied to the app bar's background color.
  final Color? surfaceTintColor;

  /// The color, opacity, and size to use for app bar icons.
  final IconThemeData? iconTheme;

  /// The color, opacity, and size to use for the icons that appear in the app bar's actions.
  final IconThemeData? actionsIconTheme;

  /// The default text style for the app bar's title.
  final TextStyle? titleTextStyle;

  /// Defines the height of the toolbar component of an app bar.
  final double? toolbarHeight;

  /// Defines the width of the leading widget.
  final double? leadingWidth;

  /// The spacing around the title content on the horizontal axis.
  final double? titleSpacing;

  /// How opaque the toolbar part of the app bar is.
  final double toolbarOpacity;

  /// How opaque the bottom part of the app bar is.
  final double bottomOpacity;

  /// The elevation that will be used if the app bar has something scrolled underneath it.
  final double? scrolledUnderElevation;

  /// A check that specifies which [ScrollNotification]s should be handled by this app bar.
  final ScrollNotificationPredicate notificationPredicate;

  /// Whether this app bar is being displayed at the top of the screen.
  final bool primary;

  /// Whether the title should be wrapped with header [Semantics].
  final bool excludeHeaderSemantics;

  /// Forces the app bar's material to be transparent.
  final bool forceMaterialTransparency;

  /// The content will be clipped (or not) according to this option.
  final Clip? clipBehavior;

  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final styles = ref.watch(textStyleProvider);

    return AppBar(
      title: title,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? palette.primary,
      foregroundColor: foregroundColor ?? palette.font,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleTextStyle: titleTextStyle ?? styles.heading1,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      scrolledUnderElevation: scrolledUnderElevation,
      notificationPredicate: notificationPredicate,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      forceMaterialTransparency: forceMaterialTransparency,
      clipBehavior: clipBehavior,
      bottom: bottom,
    );
  }
}
