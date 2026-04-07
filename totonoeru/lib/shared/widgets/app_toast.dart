import 'package:flutter/material.dart';

/// Show a toast/snackbar. Optionally includes an undo action.
///
/// Usage:
///   AppToast.show(context, 'Task deleted', onUndo: () => restore());
abstract final class AppToast {
  static void show(
    BuildContext context,
    String message, {
    VoidCallback? onUndo,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        action: onUndo != null
            ? SnackBarAction(
                label: 'Undo',
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }

  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
