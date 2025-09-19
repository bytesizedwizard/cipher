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
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);
    final textStyle = ref.watch(textStyleProvider);

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
            child: Form(
              child: CustomTextFormField(
                hintText: "Search",
                suffixIcon: Icon(
                  Icons.search,
                  color: palette.accent.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Scrollbar(
          thickness: 0,
          thumbVisibility: false,
          trackVisibility: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ListTile(
                title: const Text("Instagram"),
                titleTextStyle: textStyle.heading3,
                contentPadding: EdgeInsets.all(0),
                isThreeLine: false,
                onTap: () {
                  // copy to clipboard
                  Clipboard.setData(ClipboardData(text: "099035"));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "099035",
                      style: textStyle.heading1.copyWith(
                        fontSize: 28,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.inter().fontFamily,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "bytesizedwizard",
                      style: textStyle.body.copyWith(
                        color: palette.accent.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                style: ListTileStyle.list,
                horizontalTitleGap: 10,
                trailing: CircularTimer(seconds: 30),
              ),
              Divider(),
            ],
          ),
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
}
