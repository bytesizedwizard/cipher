import 'dart:async';

import 'package:cipher/src/providers/colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'timer.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  late final int _totalSeconds;

  // Make build accept an int -> this creates a provider *family*
  // Usage: timerNotifierProvider(30)
  @override
  int build(int totalSeconds) {
    // protect against invalid values
    _totalSeconds = totalSeconds > 0 ? totalSeconds : 1;

    // Initialize state to full duration
    state = _totalSeconds;

    // cancel any previous timer (defensive)
    _ticker?.cancel();

    // start ticking every second
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state = state - 1; // update state -> listeners rebuild
      } else {
        // Option: restart or stop. Here we restart to full duration.
        state = _totalSeconds;
      }
    });

    // ensure timer cancelled when provider is disposed
    ref.onDispose(() {
      _ticker?.cancel();
      _ticker = null;
    });

    return state;
  }

  double get remainingTime => state.toDouble();

  /// Progress from 0..1 where 1 means full elapsed and 0 means just started.
  /// (You can invert this in the widget if you prefer opposite semantics.)
  double get progress {
    if (_totalSeconds == 0) return 0.0;
    return 1.0 - (remainingTime / _totalSeconds);
  }

  /// Optional: methods to control timer manually
  void pause() {
    _ticker?.cancel();
    _ticker = null;
  }

  void resume() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state > 0) {
        state = state - 1;
      } else {
        state = _totalSeconds;
      }
    });
  }
}

class CircularTimer extends HookConsumerWidget {
  const CircularTimer({super.key, required this.seconds});

  final double seconds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(colorPaletteProvider);

    // convert to an int total seconds (protect against 0)
    final totalSeconds = seconds <= 0 ? 1 : seconds.round();

    // watch the provider instance for this totalSeconds
    final remaining = ref.watch(timerNotifierProvider(totalSeconds));

    // compute a safe progress value 0..1
    final value = (totalSeconds == 0) ? 0.0 : 1.0 - (remaining / totalSeconds);

    return CircularProgressIndicator(
      value: value.clamp(0.0, 1.0),
      backgroundColor: palette.border,
      color: palette.accent,
      strokeWidth: 8,
      trackGap: 0,
      padding: const EdgeInsets.all(0),
      strokeCap: StrokeCap.butt,
    );
  }
}
