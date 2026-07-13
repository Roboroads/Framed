import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';

/// Explains why a permission is needed before the OS prompt appears, so the
/// native dialog is never the first thing a user sees. Returns `true` if the
/// user chose to proceed (call the real permission API next) or `false` if
/// they closed it — in which case the OS permission API must never be
/// called, so a user backing out here is never recorded as a denial.
Future<bool> showPermissionRationale({
  required BuildContext context,
  required IconData icon,
  required String explanation,
}) async {
  final proceed = await showDialog<bool>(
    context: context,
    builder: (context) =>
        _PermissionRationaleDialog(icon: icon, explanation: explanation),
  );
  return proceed ?? false;
}

class _PermissionRationaleDialog extends StatelessWidget {
  const _PermissionRationaleDialog({
    required this.icon,
    required this.explanation,
  });

  final IconData icon;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(explanation, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.permissionRationale.ok),
            ),
          ],
        ),
      ),
    );
  }
}
