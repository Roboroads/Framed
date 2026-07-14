import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../theme/app_theme.dart';

/// A yes/no "are you sure" dialog (#77) — no shared pattern for this
/// existed before; every leave button needed its own confirmation. Returns
/// true only if the user tapped the confirm action, false for cancel or
/// dismissing the dialog any other way.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.confirmationDialog.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).extension<GameColors>()!.danger,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
