import 'dart:async';
import 'package:app/features/chat/domain/entities/chat_entities.dart';
import 'package:app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final WatchMessagesUseCase   _watchMessages;
  final SendMessageUseCase     _sendMessage;
  final DeleteMessageUseCase   _deleteMessage;
  final MarkAsReadUseCase      _markAsRead;

  StreamSubscription<List<MessageEntity>>? _messagesSub;

  // Context needed for send/delete calls — set on subscribe
  String _chatId     = '';
  String _myPhone    = '';
  String _otherPhone = '';

  MessagesBloc({
    required WatchMessagesUseCase watchMessages,
    required SendMessageUseCase sendMessage,
    required DeleteMessageUseCase deleteMessage,
    required MarkAsReadUseCase markAsRead,
  })  : _watchMessages = watchMessages,
        _sendMessage   = sendMessage,
        _deleteMessage = deleteMessage,
        _markAsRead    = markAsRead,
        super(MessagesInitial()) {
    on<MessagesSubscribed>(_onSubscribed);
    on<_MessagesUpdated>(_onMessagesUpdated);
    on<MessageSent>(_onMessageSent);
    on<MessageDeleted>(_onMessageDeleted);
    on<ReplySet>(_onReplySet);
    on<ReplyCleared>(_onReplyCleared);
    on<MessagesUnsubscribed>(_onUnsubscribed);
  }

  Future<void> _onSubscribed(
      MessagesSubscribed event, Emitter<MessagesState> emit) async {
    emit(MessagesLoading());
    _chatId     = event.chatId;
    _myPhone    = event.myPhone;
    _otherPhone = event.otherPhone;

    // Mark existing messages as read
    await _markAsRead(_chatId, _myPhone);

    await _messagesSub?.cancel();
    _messagesSub = _watchMessages(_chatId).listen(
      (msgs) => add(_MessagesUpdated(msgs)),
      onError: (e) => emit(MessagesError(e.toString())),
    );
  }

  void _onMessagesUpdated(
      _MessagesUpdated event, Emitter<MessagesState> emit) {
    final current = state is MessagesLoaded ? state as MessagesLoaded : null;
    emit(MessagesLoaded(
      messages:   event.messages,
      replyingTo: current?.replyingTo,
    ));
  }

  Future<void> _onMessageSent(
      MessageSent event, Emitter<MessagesState> emit) async {
    if (event.text.trim().isEmpty && event.imageUrl == null) return;

    // Clear reply immediately (optimistic)
    if (state is MessagesLoaded) {
      emit((state as MessagesLoaded).copyWith(clearReply: true));
    }

    await _sendMessage(
      chatId:      _chatId,
      myPhone:     _myPhone,
      otherPhone:  _otherPhone,
      text:        event.text.trim(),
      imageUrl:    event.imageUrl,
      replyToId:   event.replyToId,
      replyToText: event.replyToText,
    );
    // Stream will push the new message back via _MessagesUpdated
  }

  Future<void> _onMessageDeleted(
      MessageDeleted event, Emitter<MessagesState> emit) async {
    await _deleteMessage(_chatId, event.messageId);
  }

  void _onReplySet(ReplySet event, Emitter<MessagesState> emit) {
    if (state is MessagesLoaded) {
      emit((state as MessagesLoaded).copyWith(replyingTo: event.message));
    }
  }

  void _onReplyCleared(ReplyCleared event, Emitter<MessagesState> emit) {
    if (state is MessagesLoaded) {
      emit((state as MessagesLoaded).copyWith(clearReply: true));
    }
  }

  void _onUnsubscribed(
      MessagesUnsubscribed event, Emitter<MessagesState> emit) {
    _messagesSub?.cancel();
    emit(MessagesInitial());
  }

  @override
  Future<void> close() {
    _messagesSub?.cancel();
    return super.close();
  }
}
