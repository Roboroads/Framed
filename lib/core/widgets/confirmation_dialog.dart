import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../theme/app_theme.dart';

/// A yes/no "are you sure" dialog (#77) — no shared pattern for this
/// existed before; every leave button needed its own confirmation. Returns
/// true only if the user tapped the confirm action, false for cancel or
/// dismissing the dialog any other way.
///
/// Always styled as a destructive confirmation (#100) — every call site
/// confirms leaving a game, so the `false` (non-destructive) styling never
/// actually rendered. Add it back if a non-destructive confirmation ever
/// shows up.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
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
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).extension<GameColors>()!.danger,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// The confirm → leave → go-home shape shared by every leave button in the
/// app (#92): lobby, finish, and both ingame sites (death screen, corner
/// button/back gesture) all run these same three steps. What each caller
/// does on confirmation — and whether/how it surfaces failure — stays a
/// per-caller callback: #88 made the ingame sites intentionally diverge
/// from the lobby's silent best-effort swallow, so unifying failure
/// handling here would undo that.
Future<void> confirmAndLeave({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function(BuildContext context) onConfirmed,
}) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
  );
  if (!confirmed || !context.mounted) return;
  await onConfirmed(context);
  if (context.mounted) context.go('/');
}
