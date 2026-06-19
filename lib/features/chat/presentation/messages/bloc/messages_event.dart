part of 'messages_bloc.dart';

abstract class MessagesEvent {}

/// Enter a chat — start streaming messages + mark as read
class MessagesSubscribed extends MessagesEvent {
  final String chatId;
  final String myPhone;
  final String otherPhone;
  MessagesSubscribed({
    required this.chatId,
    required this.myPhone,
    required this.otherPhone,
  });
}

/// Internal — Firestore stream pushed new messages
class _MessagesUpdated extends MessagesEvent {
  final List<MessageEntity> messages;
  _MessagesUpdated(this.messages);
}

/// User tapped send
class MessageSent extends MessagesEvent {
  final String text;
  final String? imageUrl;
  final String? replyToId;
  final String? replyToText;
  MessageSent({
    required this.text,
    this.imageUrl,
    this.replyToId,
    this.replyToText,
  });
}

/// User long-pressed own message → delete
class MessageDeleted extends MessagesEvent {
  final String messageId;
  MessageDeleted(this.messageId);
}

/// User swiped a bubble to reply
class ReplySet extends MessagesEvent {
  final MessageEntity message;
  ReplySet(this.message);
}

/// User closed the reply banner
class ReplyCleared extends MessagesEvent {}

/// Leave the chat screen
class MessagesUnsubscribed extends MessagesEvent {}
