import 'package:flutter/material.dart';

import '../theme/spacing.dart';

/// The screen's decision, held below the scroll where the thumb already is.
///
/// These screens end in exactly one thing you came to do — create the game,
/// join it, start it — but the content above is long: a consent notice, a
/// roster that grows, a map. Leaving the button at the end of the list means
/// hunting for it, and worse, means the length of the legal copy decides how
/// far away the action is. Pinning it puts the decision at a fixed address.
///
/// The rule on top isn't decoration: without it the button floats over
/// content that scrolls underneath, and there's nothing saying where the page
/// stops and the choice begins.
class PinnedActionBar extends StatelessWidget {
  const PinnedActionBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: Insets.screen,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}

/// The spinner a submit button wears while it's working.
///
/// Sized to the label it replaces, so the button doesn't resize the moment
/// you press it — a button that jumps under your thumb reads as a misfire.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
