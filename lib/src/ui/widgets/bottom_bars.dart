import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bottom_bars.g.dart';

@Riverpod(keepAlive: true)
class BottomBarIndexNotifier extends _$BottomBarIndexNotifier {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

class BottomBar extends HookConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

    final currentIndex = ref.watch(bottomBarIndexProvider);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            // Update provider and navigate
            ref.read(bottomBarIndexProvider.notifier).setIndex(index);

            switch (index) {
              case 0:
                context.go("/home");
                break;
              case 1:
                context.go("/settings");
                break;
            }
          }
        },
        backgroundColor: palette.primary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: palette.accent,
        unselectedItemColor: palette.border,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            tooltip: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            tooltip: "Settings",
          ),
        ],
      ),
    );
  }
}
