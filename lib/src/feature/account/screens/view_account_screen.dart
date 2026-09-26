import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/feature/account/models/errors.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/account/widgets/delete_account_dialog.dart';
import 'package:cipher/src/feature/account/widgets/issuer_logo.dart';
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

    final accountState = ref.watch(authControllerProvider);
    final items = accountState.valueOrNull?.values ?? const <AccountView>[];
    AccountView? item;
    for (final candidate in items) {
      if (candidate.account.id == id) {
        item = candidate;
        break;
      }
    }

    final selectedItem = item;
    if (selectedItem == null) {
      return _statusScaffold(
        context,
        textStyles,
        accountState.hasError
            ? _accountErrorMessage(accountState.error)
            : 'Account is not available.',
      );
    }

    return Scaffold(
      appBar: BaseAppBar(
        title: const Text("Account Details"),
        titleTextStyle: textStyles.heading2,
        titleSpacing: 0,
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SemanticCard(
                padding: const EdgeInsets.all(0),
                border: BorderSide.none,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: IssuerLogo(
                          issuer: selectedItem.account.issuer,
                          size: 48,
                        ),
                      ),
                    ),
                    const Gap(12),
                    _itemTile(
                      "Issuer",
                      selectedItem.account.issuer.isEmpty
                          ? "N/A"
                          : selectedItem.account.issuer,
                      textStyles.label,
                      textStyles.heading2,
                      colors,
                    ),
                    const Gap(20),
                    _itemTile(
                      "Account Name",
                      selectedItem.account.label.isEmpty
                          ? "N/A"
                          : selectedItem.account.label,
                      textStyles.label,
                      textStyles.heading2,
                      colors,
                    ),
                    const Gap(20),
                    _itemTile(
                      "Passcode",
                      selectedItem.otp,
                      textStyles.label,
                      textStyles.heading1.copyWith(fontSize: 32),
                      colors,
                    ),
                    const Gap(10),
                    LinearProgressIndicator(
                      value:
                          1 -
                          selectedItem.secondsLeft /
                              AuthConstants.defaultPeriod,
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
                  Clipboard.setData(ClipboardData(text: selectedItem.otp));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied')));
                },
                semanticLabel: "Copy Passcode",
              ),
              const Gap(10),
              SemanticElevatedButton(
                icon: const Icon(Symbols.delete),
                buttonColor: colors.error,
                elevation: 0,
                labelColor: colors.fromHex("#FFFFFF"),
                iconColor: colors.fromHex('#FFFFFF'),
                border: BorderSide(color: colors.border, width: 1),
                label: "Delete Account",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return DeleteAccountDialog(id: selectedItem.account.id);
                    },
                  );
                },
                semanticLabel: "Delete Account",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusScaffold(
    BuildContext context,
    Style textStyles,
    String message,
  ) {
    return Scaffold(
      appBar: BaseAppBar(
        title: const Text("Account Details"),
        titleTextStyle: textStyles.heading2,
        titleSpacing: 0,
      ),
      body: Center(
        child: Text(
          message,
          style: textStyles.body,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _accountErrorMessage(Object? error) {
    if (error is AccountStorageIssue) {
      return error.message;
    }
    return 'Unable to load accounts.';
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
