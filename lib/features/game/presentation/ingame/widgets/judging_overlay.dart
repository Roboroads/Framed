import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_bloc.dart';
import '../ingame_state.dart';
import 'tappable_photo.dart';

/// The judging modal (#22): frame photo next to the target's reference
/// selfie, "Is this {name}?", one tap on either icon casts the vote and
/// closes. Only ever shows the queue's front entry — a second pending
/// frame from another assassin waits its turn (see [IngameJudgingEntry]).
class JudgingOverlay extends StatelessWidget {
  const JudgingOverlay({required this.entry, super.key});

  final IngameJudgingEntry entry;

  @override
  Widget build(BuildContext context) {
    final alive = Theme.of(context).extension<GameColors>()!.alive;
    final danger = Theme.of(context).extension<GameColors>()!.danger;
    final bloc = context.read<IngameBloc>();
    final loaded = entry.loaded;

    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.xl),
            child: loaded == null
                ? Center(
                    child: entry.failed
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                t.ingame.judgingLoadError,
                                textAlign: TextAlign.center,
                              ),
                              Gap.lg,
                              FilledButton(
                                onPressed: bloc.retryFrontLoad,
                                child: Text(t.ingame.judgingRetry),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.ingame.judgingTitle(name: loaded.targetName),
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      Gap.lg,
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: TappablePhoto(
                                bytes: loaded.photoBytes,
                                radius: 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                            HGap.sm,
                            Expanded(
                              child: TappablePhoto(
                                bytes: loaded.targetSelfieBytes,
                                radius: 12,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.sm,
                      Text(
                        t.ingame.judgingNudge,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Gap.lg,
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: AppTheme.semanticFilled(danger),
                              onPressed: () => bloc.castVote(
                                frameId: entry.frameId,
                                vote: false,
                              ),
                              icon: const Icon(Icons.close),
                              label: Text(t.ingame.judgingNo),
                            ),
                          ),
                          HGap.lg,
                          Expanded(
                            child: FilledButton.icon(
                              style: AppTheme.semanticFilled(alive),
                              onPressed: () => bloc.castVote(
                                frameId: entry.frameId,
                                vote: true,
                              ),
                              icon: const Icon(Icons.check),
                              label: Text(t.ingame.judgingYes),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
