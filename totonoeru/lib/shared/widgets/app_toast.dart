import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP TOAST
// Lightweight snackbar-style toast. Use showAppToast() helper.
// ─────────────────────────────────────────────────────────────────────────────

enum ToastType { success, error, info }

void showAppToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: _ToastContent(message: message, type: type),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.lg,
      ),
      duration: const Duration(seconds: 3),
      action: actionLabel != null
          ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
          : null,
    ),
  );
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({required this.message, required this.type});

  final String message;
  final ToastType type;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (type) {
      ToastType.success => (const Color(0xFF1D9E75), Icons.check_circle_rounded),
      ToastType.error   => (const Color(0xFFE24B4A), Icons.error_rounded),
      ToastType.info    => (const Color(0xFF4A90D9), Icons.info_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A18),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              message,
              style: AppTextStyles.bodyM.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
