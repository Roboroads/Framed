import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// A section label with a rule running off to the right.
///
/// The line isn't decoration: these screens stack unrelated things in one
/// scroll (the join code, the mode, the play area, the roster), and without
/// a divider they read as one long list. It encodes "a different subject
/// starts here", which is true, and it does it in less vertical space than a
/// heading and a `Divider` would.
///
/// [trailing] is for a fact about the section — a count, a status — not for
/// a control. Buttons go in the section's body where they can be found.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Row(
        children: [
          Text(
            // Uppercase with the label roles' wide tracking: this is signage
            // pointing at content, and it should never compete with the
            // content for the eye.
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          HGap.md,
          Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
          if (trailing != null) ...[HGap.md, trailing!],
        ],
      ),
    );
  }
}
