part of 'messages_bloc.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<MessageEntity> messages;
  final MessageEntity? replyingTo; // null = no active reply
  MessagesLoaded({required this.messages, this.replyingTo});

  MessagesLoaded copyWith({
    List<MessageEntity>? messages,
    MessageEntity? replyingTo,
    bool clearReply = false,
  }) =>
      MessagesLoaded(
        messages:   messages   ?? this.messages,
        replyingTo: clearReply ? null : (replyingTo ?? this.replyingTo),
      );
}

class MessagesError extends MessagesState {
  final String message;
  MessagesError(this.message);
}
