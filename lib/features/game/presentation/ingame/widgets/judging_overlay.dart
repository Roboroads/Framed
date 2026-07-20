import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/motion.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_bloc.dart';
import '../ingame_state.dart';
import 'reticle_frame.dart';
import 'tappable_photo.dart';

/// The judging modal (#22): the frame someone shot next to the target's
/// reference selfie, "Is this {name}?", one tap to vote and it closes. Only
/// ever the queue's front entry — another assassin's frame waits its turn.
///
/// The submitted frame wears the reticle brackets; the reference doesn't.
/// That's the whole disambiguation, no label needed: the bracketed one is the
/// evidence — the shot taken through the viewfinder — and the plain one is the
/// face it's being checked against. The bloc plays the shutter as this loads
/// (ingame_bloc #715), and the content resolves into focus to match it.
class JudgingOverlay extends StatelessWidget {
  const JudgingOverlay({required this.entry, super.key});

  final IngameJudgingEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alive = theme.extension<GameColors>()!.alive;
    final danger = theme.extension<GameColors>()!.danger;
    final bloc = context.read<IngameBloc>();
    final loaded = entry.loaded;

    return Positioned.fill(
      child: ColoredBox(
        color: theme.colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: Insets.screen,
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
                // Keyed by frameId so the reveal replays for each new frame in
                // the queue, not just the first.
                : _Reveal(
                    key: ValueKey(entry.frameId),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          t.ingame.judgingTitle(name: loaded.targetName),
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        Gap.lg,
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: ReticleFrame(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  child: TappablePhoto(
                                    bytes: loaded.photoBytes,
                                    radius: 8,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              HGap.md,
                              Expanded(
                                child: TappablePhoto(
                                  bytes: loaded.targetSelfieBytes,
                                  radius: 8,
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
                          style: theme.textTheme.bodySmall,
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
      ),
    );
  }
}

/// A one-shot fade-and-settle as the frame resolves into view, matched to the
/// shutter that plays when it loads. Gated for reduced motion.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Motion.gate(context, Motion.standard),
      curve: Motion.enter,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
      ),
      child: child,
    );
  }
}
