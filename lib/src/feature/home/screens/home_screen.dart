import 'package:cipher/src/feature/account/providers/auth_providers.dart';
import 'package:cipher/src/feature/account/utils/constants.dart';
import 'package:cipher/src/feature/settings/models/settings_models.dart';
import 'package:cipher/src/feature/settings/providers/settings_provider.dart';
import 'package:cipher/src/providers/colors.dart';
import 'package:cipher/src/providers/platform.dart';
import 'package:cipher/src/providers/styles.dart';
import 'package:cipher/src/ui/widgets/app_bar.dart';
import 'package:cipher/src/ui/widgets/bottom_bars.dart';
import 'package:cipher/src/ui/widgets/buttons.dart';
import 'package:cipher/src/ui/widgets/logo_type.dart';
import 'package:cipher/src/ui/widgets/text_field.dart';
import 'package:cipher/src/ui/widgets/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyle = ref.watch(textStyleProvider);

    final items = ref.watch(authControllerProvider).values;

    final searchInput = useState<String?>(null);

    final debouncedSearchText = useDebounced(
      searchInput.value,
      const Duration(milliseconds: 300),
    );

    final settings = ref.watch(settingsControllerProvider);

    useEffect(() {
      ref
          .read(authControllerProvider.notifier)
          .refreshAccounts(debouncedSearchText ?? '');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        settings.whenOrNull(
          loaded: (settings) {
            if (!settings.doNotShowBetaDisclaimer) {
              showModalBottomSheet(
                context: context,
                isDismissible: false,
                enableDrag: false,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    child: const BetaDisclaimerWidget(),
                  );
                },
                backgroundColor: palette.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }
          },
        );
      });

      return null;
    }, [debouncedSearchText]);

    return Scaffold(
      appBar: BaseAppBar(
        toolbarHeight: 125,
        titleSpacing: 25,
        title: const Logo(full: true, fit: BoxFit.contain, height: 20),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FlatIconButton(
              icon: Icon(Symbols.help),
              onPressed: () {
                context.push("/howto");
              },
              tooltip: "How to use",
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 5.0,
              bottom: 20.0,
            ),
            child: CustomTextFormField(
              hintText: "Search",
              suffixIcon: Icon(
                Icons.search,
                color: palette.accent.withValues(alpha: 0.5),
              ),
              onChanged: (value) {
                searchInput.value = value;
              },
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        minimum: const EdgeInsets.all(0),
        child: Scrollbar(
          thickness: 0,
          thumbVisibility: false,
          trackVisibility: false,
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Nothing to see here!",
                          style: textStyle.heading2,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(10),
                        Text(
                          "Tap the + button below to add your first account.",
                          style: textStyle.body.copyWith(
                            color: palette.accent.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(10),
                        Text("OR", style: textStyle.body),
                        const Gap(10),
                        Text(
                          "Tap the help button in the top right corner for a quick guide on how to use the app.",
                          style: textStyle.body.copyWith(
                            color: palette.accent.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _buildAccountList(context, items, textStyle, palette),
        ),
      ),
      bottomNavigationBar: BottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/auth/add");
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildAccountList(
    BuildContext context,
    Iterable<AccountView> items,
    Style textStyle,
    ColorPalette palette,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        return ListView(
          children: [
            for (final item in items) ...[
              ListTile(
                title: Text(item.account.issuer),
                titleTextStyle: textStyle.heading3,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                isThreeLine: false,
                onTap: () {
                  // copy to clipboard
                  Clipboard.setData(ClipboardData(text: item.otp));
                  HapticFeedback.mediumImpact();

                  final settingsNotifier = ref.read(settingsControllerProvider);

                  settingsNotifier.whenOrNull(
                    loaded: (settings) {
                      if (settings.clipboardTimeout > 0) {
                        Future.delayed(
                          Duration(milliseconds: settings.clipboardTimeout),
                          () {
                            Clipboard.setData(const ClipboardData(text: ''));
                          },
                        );
                      }
                    },
                  );

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Copied')));
                },
                onLongPress: () {
                  context.push("/auth/view", extra: item.account.id);
                },
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.otp,
                      style: textStyle.heading1.copyWith(
                        fontSize: 32,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.account.label.isNotEmpty)
                      Text(
                        item.account.label,
                        style: textStyle.body.copyWith(
                          color: palette.accent.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
                style: ListTileStyle.list,
                horizontalTitleGap: 10,
                trailing: CircularTimer(
                  secondsLeft: item.secondsLeft,
                  totalSeconds: AuthConstants.defaultPeriod,
                ),
              ),
              Divider(indent: 16, endIndent: 16),
            ],
          ],
        );
      },
    );
  }
}

class BetaDisclaimerWidget extends HookConsumerWidget {
  const BetaDisclaimerWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = ref.watch(textStyleProvider);
    final palette = ref.watch(colorPaletteProvider);

    final packageInfo = ref.watch(platformInfoProvider);

    final doNotShowAgain = useState<bool>(false);

    return packageInfo.maybeWhen(
      orElse: () => const CircularProgressIndicator(),
      data: (data) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Logo(full: true, height: 25),
              const SizedBox(height: 20),
              Text(
                "This version of ${data.appName} is still under active development, and while we’ve built it with privacy and security at the core, occasional issues may occur.",
                style: textStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const Gap(10),
              Text(
                "Please remember that ${data.appName} stores all authentication data locally on your device. We do not back up, sync, or have access to your secrets.",
                style: textStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const Gap(10),
              Text(
                "For your safety, ensure that you have securely saved the recovery codes for any accounts you add. If you are locked out, those recovery codes will be the only way to regain access to your accounts.",
                style: textStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              const Gap(20),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      checkColor: palette.primary,
                      value: doNotShowAgain.value,
                      activeColor: palette.accent,
                      onChanged: (value) {
                        doNotShowAgain.value = value ?? false;
                      },
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      "Do not show this message again",
                      style: textStyles.body,
                    ),
                  ),
                ],
              ),
              const Gap(20),
              SemanticElevatedButton(
                label: "I Understand",
                onPressed: () {
                  if (doNotShowAgain.value) {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .acknowledgeBetaDisclaimer();
                  }
                  Navigator.of(context).pop();
                },
                semanticLabel: "I Understand Beta Disclaimer Button",
              ),
              const Gap(10),
            ],
          ),
        );
      },
    );
  }
}
