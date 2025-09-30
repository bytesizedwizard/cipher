import 'package:cipher/src/feature/auth/providers/auth_providers.dart';
import 'package:cipher/src/feature/auth/utils/constants.dart';
import 'package:cipher/src/providers/colors.dart';
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
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

    useEffect(() {
      ref
          .read(authControllerProvider.notifier)
          .refreshAccounts(debouncedSearchText ?? '');

      return null;
    }, [debouncedSearchText]);

    return Scaffold(
      appBar: BaseAppBar(
        toolbarHeight: 125,
        titleSpacing: 25,
        title: Logo(height: 25, full: true),
        elevation: 0,
        actions: [
          FlatIconButton(icon: Icon(Symbols.more_vert), onPressed: () {}),
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
                          "Nothing to see here...",
                          style: textStyle.heading2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tap the + button below to add your first account.",
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Copied')));
            },
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.otp,
                  style: textStyle.heading1.copyWith(
                    fontSize: 28,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.inter().fontFamily,
                  ),
                ),
                const SizedBox(width: 5),
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
          Divider(),
        ],
      ],
    );
  }
}
