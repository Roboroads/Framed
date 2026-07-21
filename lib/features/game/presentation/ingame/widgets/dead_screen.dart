import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/chat/chat_message.dart';
import '../../../../../core/chat/chat_panel.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/session/game_session.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/framed_icons.dart';
import '../../../../../core/theme/motion.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/util/duration_format.dart';
import '../../../../../core/widgets/full_screen_photo_page.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_bloc.dart';
import 'leave_ingame.dart';
import 'reticle_frame.dart';

/// How you died, how long you survived, the photo that framed you, who your
/// assassin was (#23), and the dead chat everyone out of the game shares
/// (#24, IDEA.md "Screens" — death screen).
///
/// The moment is big on arrival — the frame that ended you, held in the
/// dead-tinted reticle — and collapses to a slim bar once you turn to the
/// chat (scroll, or the keyboard opening), because the chat is where you
/// actually live for the rest of the game (#108). Tapping the bar brings
/// the moment back. All controls stay in the content flow: #90 already
/// proved overlaying buttons on this screen collides with the chat's Send.
class DeadScreen extends StatefulWidget {
  const DeadScreen({
    required this.cause,
    required this.killerName,
    required this.survivedSeconds,
    required this.photoBytes,
    required this.chat,
    required this.otherDeadPlayerNames,
    super.key,
  });

  final String cause;
  final String? killerName;
  final int survivedSeconds;
  final Uint8List? photoBytes;
  final List<ChatMessage> chat;
  final List<String> otherDeadPlayerNames;

  @override
  State<DeadScreen> createState() => _DeadScreenState();
}

class _DeadScreenState extends State<DeadScreen> {
  // Set by scrolling the chat or focusing its input (viewInsets can't be
  // the keyboard signal here: the Scaffold consumes them when it resizes,
  // so they read 0 inside the body). Cleared only by tapping the bar.
  bool _collapsed = false;

  void _collapse() {
    if (!_collapsed) setState(() => _collapsed = true);
  }

  String get _title => switch (widget.cause) {
    'mia' => t.ingame.deadTitleMia,
    // Only reachable via a crash-resume racing the leave RPC itself (#78) —
    // a normal leave ends the session and navigates home before this
    // screen would ever render.
    'left' => t.ingame.deadTitleLeft,
    _ => t.ingame.deadTitleFramed,
  };

  String? get _causeLine => switch (widget.cause) {
    'mia' => t.ingame.deadCauseMia,
    'left' => t.ingame.deadCauseLeft,
    _ when widget.killerName != null => t.ingame.deadKilledBy(
      name: widget.killerName!,
    ),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    // isActive guard: leaving ends the session before navigation finishes,
    // and a late dead-chat message can rebuild this screen in that window.
    final session = getIt<GameSession>();
    final myPlayerId = session.isActive ? session.playerId : '';
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          AnimatedSize(
            duration: Motion.gate(context, Motion.standard),
            curve: Motion.enter,
            alignment: Alignment.topCenter,
            child: _collapsed
                ? _CollapsedMoment(
                    title: _title,
                    causeLine: _causeLine,
                    survivedSeconds: widget.survivedSeconds,
                    photoBytes: widget.photoBytes,
                    onExpand: () {
                      // Dropping the input's focus too — expanding back over
                      // an open keyboard would re-hide the chat it covers.
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => _collapsed = false);
                    },
                  )
                // Capped so some chat always stays visible, and scrollable
                // within the cap: a shrunken body (keyboard mid-animation,
                // split-screen, large text scale) must squeeze the moment,
                // never blow out the Column. The chat reservation shrinks
                // with the body so the cap can never exceed what's there.
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          constraints.maxHeight -
                          (constraints.maxHeight * 0.4).clamp(0.0, 200.0),
                    ),
                    child: SingleChildScrollView(
                      child: _ExpandedMoment(
                        title: _title,
                        causeLine: _causeLine,
                        survivedSeconds: widget.survivedSeconds,
                        photoBytes: widget.photoBytes,
                        otherDeadPlayerNames: widget.otherDeadPlayerNames,
                      ),
                    ),
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SafeArea(
              top: false,
              // Scroll notifications bubble up out of the ChatPanel's list,
              // and the Focus ancestor reports its input taking focus (the
              // keyboard opening); either way, turning to the chat is the
              // signal the moment has had its moment.
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  _collapse();
                  return false;
                },
                child: Focus(
                  skipTraversal: true,
                  canRequestFocus: false,
                  onFocusChange: (hasFocus) {
                    if (hasFocus) _collapse();
                  },
                  child: ChatPanel(
                    chat: widget.chat,
                    myPlayerId: myPlayerId,
                    onSend: (text) =>
                        context.read<IngameBloc>().sendChatMessage(text),
                    emptyText: t.ingame.deadChatEmpty,
                    hintText: t.ingame.deadChatHint,
                    sendTooltip: t.ingame.deadChatSendButton,
                    listPadding: const EdgeInsets.symmetric(
                      horizontal: Space.lg,
                      vertical: Space.sm,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The full moment: the frame that ended you (or the reticle alone when
/// there's no photo — MIA and left deaths), title, cause, survival time in
/// mono, who else is out, and the leave affordance with its consequences.
class _ExpandedMoment extends StatelessWidget {
  const _ExpandedMoment({
    required this.title,
    required this.causeLine,
    required this.survivedSeconds,
    required this.photoBytes,
    required this.otherDeadPlayerNames,
  });

  final String title;
  final String? causeLine;
  final int survivedSeconds;
  final Uint8List? photoBytes;
  final List<String> otherDeadPlayerNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dead = theme.extension<GameColors>()!.dead;
    final height = MediaQuery.sizeOf(context).height;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height * 0.3),
            child: ReticleFrame(
              color: dead,
              child: photoBytes != null
                  ? GestureDetector(
                      onTap: () =>
                          FullScreenPhotoPage.open(context, photoBytes!),
                      child: ClipRRect(
                        borderRadius: AppTheme.corner,
                        child: Image.memory(photoBytes!, fit: BoxFit.cover),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 3 / 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: AppTheme.corner,
                        ),
                        child: Center(
                          child: FramedIcons(
                            FramedIcon.target,
                            size: 72,
                            color: dead,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          Gap.lg,
          Text(
            title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          if (causeLine case final line?) ...[
            Gap.xs,
            Text(line, textAlign: TextAlign.center),
          ],
          Gap.sm,
          Text(
            formatDuration(survivedSeconds),
            style: AppTheme.mono(
              theme.textTheme.displaySmall!,
            ).copyWith(color: dead),
          ),
          Text(
            t.ingame.deadSurvivedCaption,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (otherDeadPlayerNames.isNotEmpty) ...[
            Gap.sm,
            Text(
              t.ingame.deadAlsoOut(names: otherDeadPlayerNames.join(', ')),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          Gap.md,
          // No leave option existed on this screen before #77 — only
          // force-closing the app. Dead-only: IDEA.md "Game rules"'
          // no-mid-game-quit still binds the living, this screen only
          // ever renders once already dead. The consequences line lives in
          // the confirmation dialog; the warning here stays one glance.
          Text(
            t.ingame.deadLeaveWarning,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.sm,
          OutlinedButton.icon(
            onPressed: () => _confirmLeave(context),
            icon: const Icon(Icons.logout),
            label: Text(t.ingame.deadLeaveButton),
          ),
        ],
      ),
    );
  }
}

/// The slim bar the moment collapses to: thumbnail, cause, mono survival
/// time, and the same leave affordance so collapsing never hides it (#90's
/// lesson: this screen's controls must not depend on layering). Tapping
/// the bar itself re-expands.
class _CollapsedMoment extends StatelessWidget {
  const _CollapsedMoment({
    required this.title,
    required this.causeLine,
    required this.survivedSeconds,
    required this.photoBytes,
    required this.onExpand,
  });

  final String title;
  final String? causeLine;
  final int survivedSeconds;
  final Uint8List? photoBytes;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dead = theme.extension<GameColors>()!.dead;
    return InkWell(
      onTap: onExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.sm,
        ),
        child: Row(
          children: [
            if (photoBytes != null)
              ClipRRect(
                borderRadius: AppTheme.corner,
                child: Image.memory(
                  photoBytes!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              )
            else
              FramedIcons(FramedIcon.target, size: 28, color: dead),
            HGap.md,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  if (causeLine case final line?)
                    Text(
                      line,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            HGap.md,
            Text(
              formatDuration(survivedSeconds),
              style: AppTheme.mono(
                theme.textTheme.titleMedium!,
              ).copyWith(color: dead),
            ),
            IconButton(
              onPressed: () => _confirmLeave(context),
              icon: const Icon(Icons.logout),
              tooltip: t.ingame.deadLeaveButton,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmLeave(BuildContext context) => confirmAndLeaveIngame(
  context,
  title: t.ingame.deadLeaveConfirmTitle,
  message: t.ingame.deadLeaveConfirmBody,
  confirmLabel: t.ingame.deadLeaveConfirmButton,
);
