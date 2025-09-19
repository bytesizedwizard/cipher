import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A text input field that is form-compatible, accessible, and
/// usable both inside and outside of a Form.
class CustomTextFormField extends ConsumerWidget {
  const CustomTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.semanticLabel,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.textInputType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.textStyle,
    this.hintStyle,
    this.labelStyle,
    this.helperStyle,
    this.borderRadius = 6.0,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
    this.isRequired = false,
    this.autovalidateMode,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Optional label shown above the field.
  final String? label;

  /// Hint shown inside the field.
  final String? hintText;

  /// Supporting helper text below the input.
  final String? helperText;

  /// Explicit semantics label for screen readers. Falls back to label or hint.
  final String? semanticLabel;

  final TextEditingController? controller;
  final String? initialValue;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when user submits (e.g., presses enter).
  final ValueChanged<String>? onFieldSubmitted;

  /// FormField onSaved callback.
  final FormFieldSetter<String>? onSaved;

  /// Validation logic.
  final FormFieldValidator<String>? validator;

  final TextInputType textInputType;
  final bool obscureText;
  final int maxLines;
  final bool enabled;

  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;

  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  /// Whether the field is required (for accessibility announcement).
  final bool isRequired;

  /// Controls when validation is run.
  final AutovalidateMode? autovalidateMode;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final styles = ref.watch(textStyleProvider);

    // Derive the semantics label: prefer explicit, then visible label, then hint.
    final effectiveSemanticsLabel = semanticLabel ?? label ?? hintText ?? '';
    final isDateInput = textInputType == TextInputType.datetime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label!, style: labelStyle ?? styles.label),
          ),
        Semantics(
          container: true,
          label: effectiveSemanticsLabel,
          hint: hintText,
          textField: true,
          enabled: enabled,
          child: GestureDetector(
            onTap: isDateInput && enabled ? () => _selectDate(context) : null,
            child: AbsorbPointer(
              absorbing: isDateInput,
              child: TextFormField(
                controller: controller,
                initialValue: controller == null ? initialValue : null,
                keyboardType: textInputType,
                obscureText: obscureText,
                maxLines: maxLines,
                enabled: enabled,
                onChanged: onChanged,
                onFieldSubmitted: onFieldSubmitted,
                onSaved: onSaved,
                validator: validator,
                autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
                style: textStyle ?? styles.body,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: hintText,
                  hintStyle:
                      hintStyle ??
                      styles.body.copyWith(
                        color: palette.font.withValues(alpha: 0.35),
                      ),
                  helperText: helperText,
                  helperStyle: helperStyle,
                  errorStyle: styles.body.copyWith(color: palette.error),
                  contentPadding: contentPadding,
                  prefixIcon: prefixIcon,
                  suffixIcon: suffixIcon,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: palette.accent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: palette.error),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(color: palette.error, width: 1.5),
                  ),
                  filled: true,
                  fillColor: palette.accent.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      // Format date as dd-MM-yyyy
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      controller?.text = formatted;
      if (onChanged != null) {
        onChanged!(formatted);
      }
    }
  }
}
