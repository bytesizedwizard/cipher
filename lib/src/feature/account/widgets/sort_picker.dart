import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Bottom sheet for selecting account sort order.
///
/// Follows DESIGN.md radio-group conventions:
/// `rounded.sm` card, `accent` selected state, `heading3` for options.
class SortPickerSheet extends ConsumerWidget {
  const SortPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);
    final settings = ref.watch(settingsControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sort Accounts', style: textStyles.heading2),
          const Gap(2),
          Text(
            'Choose how your accounts are ordered.',
            style: textStyles.body.copyWith(
              color: palette.accent.withValues(alpha: 0.7),
            ),
          ),
          const Gap(16),
          settings.maybeWhen(
            orElse: () => const LinearProgressIndicator(),
            loaded: (s) => SemanticRadioButtonGroup<AccountSortField>(
              options: AccountSortField.values
                  .map((f) => RadioButtonOption(value: f, label: f.displayName))
                  .toList(),
              groupValue: s.sortField,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setSortField(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          const Gap(10),
        ],
      ),
    );
  }
}
