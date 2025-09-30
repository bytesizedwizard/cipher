import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CircularTimer extends HookConsumerWidget {
  const CircularTimer({
    super.key,
    required this.totalSeconds,
    required this.secondsLeft,
  });

  final int totalSeconds;
  final int secondsLeft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

    // compute a safe progress value 0..1
    final value = (totalSeconds == 0)
        ? 0.0
        : 1.0 - (secondsLeft / totalSeconds);

    return CircularProgressIndicator(
      value: value.clamp(0.0, 1.0),
      backgroundColor: palette.border,
      color: palette.accent,
      strokeWidth: 3,
      trackGap: 0,
      padding: const EdgeInsets.all(0),
      strokeCap: StrokeCap.butt,
    );
  }
}
