import 'package:flutter/material.dart';

import 'chat_bubble.dart';
import 'chat_limits.dart';
import 'chat_message.dart';

/// Empty-state text, then a reversed, newest-last message list, then a
/// composer field with a send button (#91) -- shared shape for the ingame
/// dead chat and the finish screen's meetup chat, which used to be two
/// copies of the same widget tree. [onSend] and the three strings are the
/// only things that differ between call sites; each caller owns its own
/// layout (SafeArea, list padding, fixed height) around this widget.
class ChatPanel extends StatefulWidget {
  const ChatPanel({
    required this.chat,
    required this.myPlayerId,
    required this.onSend,
    required this.emptyText,
    required this.hintText,
    required this.sendTooltip,
    this.listPadding = EdgeInsets.zero,
    super.key,
  });

  final List<ChatMessage> chat;
  final String myPlayerId;
  final ValueChanged<String> onSend;
  final String emptyText;
  final String hintText;
  final String sendTooltip;
  final EdgeInsetsGeometry listPadding;

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  final _composer = TextEditingController();

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text;
    if (text.trim().isEmpty) return;
    widget.onSend(text);
    _composer.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.chat.isEmpty
              ? Center(
                  child: Text(
                    widget.emptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.builder(
                  reverse: true,
                  padding: widget.listPadding,
                  itemCount: widget.chat.length,
                  itemBuilder: (context, i) {
                    final message = widget.chat[widget.chat.length - 1 - i];
                    return ChatBubble(
                      message: message,
                      isMine: message.senderId == widget.myPlayerId,
                    );
                  },
                ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _composer,
                decoration: InputDecoration(hintText: widget.hintText),
                maxLength: maxChatMessageLength,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _send,
              tooltip: widget.sendTooltip,
            ),
          ],
        ),
      ],
    );
  }
}
