import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/chat/chat_message.dart';
import '../../../../../core/chat/chat_panel.dart';
import '../../../../../core/di/injector.dart';
import '../../../../../core/session/game_session.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../core/util/duration_format.dart';
import '../../../../../i18n/strings.g.dart';
import '../ingame_bloc.dart';
import 'leave_ingame.dart';
import 'tappable_photo.dart';

/// How you died, how long you survived, the photo that framed you, who your
/// assassin was (#23), and the dead chat everyone out of the game shares
/// (#24, IDEA.md "Screens" — death screen).
class DeadScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final myPlayerId = getIt<GameSession>().playerId;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (photoBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.lg),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: TappablePhoto(
                      bytes: photoBytes!,
                      radius: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                switch (cause) {
                  'mia' => t.ingame.deadTitleMia,
                  // Only reachable via a crash-resume racing the leave RPC
                  // itself (#78) — a normal leave ends the session and
                  // navigates home before this screen would ever render.
                  'left' => t.ingame.deadTitleLeft,
                  _ => t.ingame.deadTitleFramed,
                },
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Gap.lg,
              if (cause == 'mia')
                Text(t.ingame.deadCauseMia, textAlign: TextAlign.center)
              else if (cause == 'left')
                Text(t.ingame.deadCauseLeft, textAlign: TextAlign.center)
              else if (killerName != null)
                Text(
                  t.ingame.deadKilledBy(name: killerName!),
                  textAlign: TextAlign.center,
                ),
              Gap.sm,
              Text(
                t.ingame.deadSurvivedFor(time: formatDuration(survivedSeconds)),
                textAlign: TextAlign.center,
              ),
              if (otherDeadPlayerNames.isNotEmpty) ...[
                Gap.sm,
                Text(
                  t.ingame.deadAlsoOut(names: otherDeadPlayerNames.join(', ')),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              Gap.lg,
              Text(
                t.ingame.deadLeaveWarning,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              Gap.sm,
              // No leave option existed on this screen before #77 — only
              // force-closing the app. Dead-only: IDEA.md "Game rules"'
              // no-mid-game-quit still binds the living, this screen only
              // ever renders once already dead.
              OutlinedButton.icon(
                onPressed: () => confirmAndLeaveIngame(
                  context,
                  title: t.ingame.deadLeaveConfirmTitle,
                  message: t.ingame.deadLeaveConfirmBody,
                  confirmLabel: t.ingame.deadLeaveConfirmButton,
                ),
                icon: const Icon(Icons.logout),
                label: Text(t.ingame.deadLeaveButton),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SafeArea(
            top: false,
            child: ChatPanel(
              chat: chat,
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
      ],
    );
  }
}
