import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddAccountErrorDialog extends HookConsumerWidget {
  final ParseException error;

  const AddAccountErrorDialog({super.key, required this.error});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);

    return AlertDialog(
      elevation: 10,
      shadowColor: colors.primary.withOpacity(0.5),
      backgroundColor: colors.primary,
      title: Row(
        children: [
          Icon(Icons.error, color: colors.error),
          const Gap(10),
          const Text('Error'),
        ],
      ),
      titleTextStyle: textStyles.heading2,
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'An error occurred while adding the account. Please ensure the details are correct and try again.',
              style: textStyles.body,
            ),
            const Gap(20),
            Text(
              "Error Code:",
              style: textStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(4),
            Text(
              error.code.name,
              style: textStyles.body.copyWith(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            Text(
              'Error Details:',
              style: textStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
            const Gap(4),
            Text(
              error.message,
              style: textStyles.body.copyWith(
                color: colors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(20),
            SemanticElevatedButton(
              label: "Close",
              onPressed: () {
                context.pop();
              },
              semanticLabel: "Close error dialog",
            ),
          ],
        ),
      ),
    );
  }
}
