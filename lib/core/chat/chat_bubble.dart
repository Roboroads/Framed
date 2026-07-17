import 'package:flutter/material.dart';

import 'chat_message.dart';
import '../theme/spacing.dart';
import '../theme/app_theme.dart';

/// One chat bubble, aligned right and tinted for the local player's own
/// messages (#91) -- shared by the ingame dead chat and the finish
/// screen's meetup chat.
class ChatBubble extends StatelessWidget {
  const ChatBubble({required this.message, required this.isMine, super.key});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: Space.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: AppTheme.corner,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMine)
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
