import 'dart:math' show pi;

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

    final value = (totalSeconds == 0)
        ? 0.0
        : 1.0 - (secondsLeft / totalSeconds);

    final isUrgent = secondsLeft <= 5;

    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _CircularTimerPainter(
          progress: value.clamp(0.0, 1.0),
          trackColor: palette.border,
          progressColor: isUrgent
              ? const Color(0xFFE53935)
              : palette.accent,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

class _CircularTimerPainter extends CustomPainter {
  _CircularTimerPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final remaining = 2 * pi * (1.0 - progress);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      -remaining, // counterclockwise from top → ring drains clockwise
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularTimerPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor;
}
