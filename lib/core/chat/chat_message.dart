import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// One decrypted chat message (#24, #79), history or live, ready to
/// render -- shared shape for both the ingame dead chat and the finish
/// screen's meetup chat (#91), which used to declare byte-identical
/// models under different names. [senderName] is already resolved from
/// the roster.
@freezed
sealed class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String senderName,
    required String text,
    required DateTime createdAt,
  }) = _ChatMessage;
}
