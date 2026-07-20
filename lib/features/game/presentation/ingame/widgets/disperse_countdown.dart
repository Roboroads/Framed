import 'package:flutter/material.dart';

import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import 'breathe.dart';
import 'countdown_text.dart';

/// The opening beat: no target yet, just a clock and an instruction to get
/// away from everyone. The reticle overhead is still hunting — dimmed and
/// breathing, not locked — because it hasn't found your target either. When
/// the clock hits zero the game hands you one.
class DisperseCountdown extends StatelessWidget {
  const DisperseCountdown({required this.endsAt, super.key});

  final DateTime endsAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Centred when it fits, scrollable when it doesn't, so the instruction
    // can't be clipped off the bottom at large text scale on a small screen.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: Insets.screen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Breathe(
                    child: FramedIcons(
                      FramedIcon.reticle,
                      size: 96,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Gap.xxl,
                  Text(
                    t.ingame.disperseTitle,
                    style: theme.textTheme.headlineMedium,
                  ),
                  Gap.lg,
                  CountdownText(
                    deadline: endsAt,
                    builder: (context, time) =>
                        Text(time, style: theme.textTheme.displayLarge),
                  ),
                  Gap.lg,
                  Text(
                    t.ingame.disperseInstruction,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
