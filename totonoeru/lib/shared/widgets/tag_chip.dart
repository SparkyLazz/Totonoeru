import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ── Category Chip ─────────────────────────────────────────────────────────────

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.name,
    required this.colorHex,
    this.nameJp,
    this.onTap,
    this.isSelected = false,
  });

  final String name;
  final String colorHex;
  final String? nameJp;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.accentFromHex(colorHex);
    final bg = isSelected ? color.withOpacity(0.15) : color.withOpacity(0.08);
    final border = isSelected ? color : color.withOpacity(0.3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            if (nameJp != null) ...[
              const SizedBox(width: 4),
              Text(
                nameJp!,
                style: TextStyle(
                  fontFamily: 'NotoSansJP',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: color.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Priority Chip ─────────────────────────────────────────────────────────────

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority, this.onTap});

  final String priority; // 'high' | 'medium' | 'low'
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'high' => ('High', AppColors.priorityHigh),
      'low' => ('Low', AppColors.priorityLow),
      _ => ('Medium', AppColors.priorityMedium),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ),
    );
  }
}
