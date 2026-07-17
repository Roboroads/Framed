import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../theme/spacing.dart';

/// A [Dialog] whose content starts at the top and whose way out is at the
/// bottom (#94 originally put the two copies of this scaffold in one place).
///
/// The close button used to be an X in a row of its own above the content,
/// which bought a full button's height of empty space across the top of
/// every dialog before a single word was read. A dialog is a thing you read
/// and then dismiss, so the reading starts at the top and the dismissal
/// waits at the end, where a thumb already is and where the eye arrives last.
class ClosableDialog extends StatelessWidget {
  const ClosableDialog({required this.child, this.title, super.key});

  final Widget child;

  /// Optional heading. Without one the content speaks for itself.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: Insets.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: Theme.of(context).textTheme.headlineSmall),
              Gap.md,
            ],
            // Flexible, not fixed: a dialog holding a long body scrolls
            // inside itself rather than growing past the screen and taking
            // the close button with it.
            Flexible(child: child),
            Gap.lg,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(t.common.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
