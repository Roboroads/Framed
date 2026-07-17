import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// A [Dialog] with a top-right close button above [child] (#94) -- the
/// join-QR dialog and the game-settings info dialog were two copies of
/// this exact scaffold.
class ClosableDialog extends StatelessWidget {
  const ClosableDialog({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}
