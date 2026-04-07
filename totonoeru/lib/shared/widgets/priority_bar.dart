import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Vertical colored bar displayed on the left edge of task cards
/// to indicate priority level at a glance.
class PriorityBar extends StatelessWidget {
  const PriorityBar({
    super.key,
    required this.priority,
    this.height = 56,
    this.width = 3.5,
    this.borderRadius = 2,
  });

  final String priority; // 'high' | 'medium' | 'low'
  final double height;
  final double width;
  final double borderRadius;

  Color get _color => switch (priority) {
        'high' => AppColors.priorityHigh,
        'low' => AppColors.priorityLow,
        _ => AppColors.priorityMedium,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
