import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import 'countdown_text.dart';

class DisperseCountdown extends StatelessWidget {
  const DisperseCountdown({required this.endsAt, super.key});

  final DateTime endsAt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t.ingame.disperseTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Gap.lg,
          CountdownText(
            deadline: endsAt,
            builder: (context, time) =>
                Text(time, style: Theme.of(context).textTheme.displayLarge),
          ),
          Gap.lg,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              t.ingame.disperseInstruction,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
