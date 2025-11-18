import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DeleteAccountDialog extends HookConsumerWidget {
  final String id;

  const DeleteAccountDialog({super.key, required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(colorPaletteProvider);
    final textStyles = ref.watch(textStyleProvider);

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final canSubmit = useState(false);

    return AlertDialog(
      backgroundColor: colors.primary,
      title: Row(
        children: [
          Icon(Icons.error, color: colors.warning),
          const Gap(10),
          const Text('Warning'),
        ],
      ),
      titleTextStyle: textStyles.heading2,
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              'Deleting your account is permanent and cannot be undone. All your data and codes associated with this account will be lost.',
              style: textStyles.body,
            ),
            const Gap(20),
            Text(
              'Before deleting, please make sure you have removed 2FA from your account. Are you sure you want to proceed?',
              style: textStyles.body,
            ),
            const Gap(40),
            RichText(
              text: TextSpan(
                style: textStyles.body,
                children: [
                  const TextSpan(text: 'Type '),
                  TextSpan(
                    text: 'I understand',
                    style: textStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' below to confirm'),
                ],
              ),
            ),
            const Gap(10),
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              canPop: false,
              child: CustomTextFormField(
                hintText: 'I understand',
                onChanged: (value) {
                  canSubmit.value = value == 'I understand';
                },
                validator: (value) {
                  if (value != 'I understand') {
                    return '';
                  }
                  return null;
                },
              ),
            ),
            const Gap(10),
            SemanticElevatedButton(
              label: "Delete",
              buttonColor: colors.error,
              labelColor: colors.fromHex('#FFFFFF'),
              onPressed: canSubmit.value
                  ? () async {
                      if (formKey.currentState!.validate()) {
                        // Proceed with account deletion
                        await ref
                            .read(authControllerProvider.notifier)
                            .deleteAccount(id);

                        if (context.mounted) {
                          context.go(
                            '/home',
                          ); // Navigate to home or appropriate screen
                        }
                      }
                    }
                  : null,
              semanticLabel: "Confirm Delete Account",
            ),
            const Gap(10),
            SemanticTextButton(
              label: "Cancel",
              onPressed: () {
                context.pop();
              },
              semanticLabel: "Cancel Delete Account",
            ),
          ],
        ),
      ),
    );
  }
}
