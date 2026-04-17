// lib/features/focus/widgets/focus_ring.dart
// Custom ring painter — DM design system colours

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FocusRingPainter extends CustomPainter {
  const FocusRingPainter({
    required this.progress,  // 0.0–1.0 (1.0 = full)
    required this.isBreak,
    required this.accentColor,
    required this.trackColor,
  });

  final double progress;
  final bool isBreak;
  final Color accentColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 8.0;
    const startAngle = -math.pi / 2; // top

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = isBreak ? AppColors.priorityMedium : accentColor;

    // track
    canvas.drawCircle(center, radius, trackPaint);

    // progress arc
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(FocusRingPainter old) =>
      old.progress != progress ||
          old.isBreak != isBreak ||
          old.accentColor != accentColor ||
          old.trackColor != trackColor;
}