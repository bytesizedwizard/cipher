import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/app_bar.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class ViewAccountScreen extends ConsumerWidget {
  final String id;

  const ViewAccountScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = ref.watch(textStyleProvider);
    final colors = ref.watch(colorPaletteProvider);

    final items = ref.watch(authControllerProvider).values;
    final item = items.firstWhere((element) => element.account.id == id);

    return Scaffold(
      appBar: BaseAppBar(
        title: const Text("Account Details"),
        titleTextStyle: textStyles.heading2,
        titleSpacing: 0,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SemanticCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _itemTile(
                      "Issuer",
                      item.account.issuer.isEmpty ? "N/A" : item.account.issuer,
                      textStyles.label,
                      textStyles.heading2,
                      colors,
                    ),
                    const Gap(20),
                    _itemTile(
                      "Account Name",
                      item.account.label.isEmpty ? "N/A" : item.account.label,
                      textStyles.label,
                      textStyles.heading2,
                      colors,
                    ),
                    const Gap(20),
                    _itemTile(
                      "Passcode",
                      item.otp,
                      textStyles.label,
                      textStyles.heading1.copyWith(fontSize: 32),
                      colors,
                    ),
                    const Gap(10),
                    LinearProgressIndicator(
                      value: 1 - item.secondsLeft / AuthConstants.defaultPeriod,
                      color: colors.accent,
                      backgroundColor: colors.accent.withValues(alpha: 0.1),
                    ),
                    const Gap(10),
                  ],
                ),
              ),
              const Gap(20),
              SemanticElevatedButton(
                icon: const Icon(Symbols.content_copy),
                buttonColor: colors.primary,
                elevation: 0,
                labelColor: colors.accent,
                iconColor: colors.accent,
                border: BorderSide(color: colors.border, width: 1),
                label: "Copy Passcode",
                onPressed: () {
                  // copy to clipboard
                  Clipboard.setData(ClipboardData(text: item.otp));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied')));
                },
                semanticLabel: "Copy Passcode",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemTile(
    String title,
    String subtitle,
    TextStyle titleStyle,
    TextStyle subtitleStyle,
    ColorPalette colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: titleStyle),
        const Gap(2),
        Text(subtitle, style: subtitleStyle),
      ],
    );
  }
}
