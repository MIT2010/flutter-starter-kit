import 'package:flutter/material.dart';

/// A yes/no confirmation modal.
///
/// Resolves to `true` **only** when the confirm action is tapped. Every
/// other way out — the cancel button, a tap on the barrier, the system
/// back button/gesture — resolves to `false`, so a caller can always treat
/// a falsy result as "don't proceed":
///
/// ```dart
/// if (await confirmDialog(context, title: 'Discard changes?', message: '…') &&
///     context.mounted) {
///   // ... do the thing
/// }
/// ```
///
/// This is intentionally unstyled — a plain [AlertDialog]. It is a
/// control-flow convenience (the "dismiss means no" contract is the point),
/// not a design component. Restyle it, or replace it, when the project has
/// a real look.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
