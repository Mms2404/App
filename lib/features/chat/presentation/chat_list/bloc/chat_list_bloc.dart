import 'dart:async';
import 'package:app/features/chat/domain/entities/chat_entities.dart';
import 'package:app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final WatchChatsUseCase _watchChats;
  final SearchUsersUseCase _searchUsers;
  final OpenOrCreateChatUseCase _openOrCreateChat;

  StreamSubscription<List<ChatEntity>>? _chatsSub;
  List<ChatEntity> _currentChats = [];

  ChatListBloc({
    required WatchChatsUseCase watchChats,
    required SearchUsersUseCase searchUsers,
    required OpenOrCreateChatUseCase openOrCreateChat,
  })  : _watchChats       = watchChats,
        _searchUsers      = searchUsers,
        _openOrCreateChat = openOrCreateChat,
        super(ChatListInitial()) {
    on<ChatListSubscribed>(_onSubscribed);
    on<_ChatsUpdated>(_onChatsUpdated);
    on<UserSearched>(_onUserSearched);
    on<ChatOpened>(_onChatOpened);
    on<ChatListUnsubscribed>(_onUnsubscribed);
  }

  Future<void> _onSubscribed(
      ChatListSubscribed event, Emitter<ChatListState> emit) async {
    emit(ChatListLoading());
    await _chatsSub?.cancel();
    _chatsSub = _watchChats(event.myPhone).listen(
      (chats) => add(_ChatsUpdated(chats)),
      onError: (e) => emit(ChatListError(e.toString())),
    );
  }

  void _onChatsUpdated(_ChatsUpdated event, Emitter<ChatListState> emit) {
    _currentChats = event.chats;
    emit(ChatListLoaded(event.chats));
  }

  Future<void> _onUserSearched(
      UserSearched event, Emitter<ChatListState> emit) async {
    if (event.query.trim().length < 2) {
      emit(ChatListLoaded(_currentChats));
      return;
    }
    final results = await _searchUsers(event.query.trim(), event.myPhone);
    emit(ContactSearchResults(users: results, chats: _currentChats));
  }

  Future<void> _onChatOpened(
      ChatOpened event, Emitter<ChatListState> emit) async {
    final chatId = await _openOrCreateChat(
      myPhone:    event.myPhone,
      myName:     event.myName,
      otherPhone: event.otherPhone,
      otherName:  event.otherName,
    );
    emit(ChatNavigateToMessages(
      chatId:     chatId,
      otherPhone: event.otherPhone,
      chats:      _currentChats,
    ));
    // Immediately settle back to loaded so BlocListener doesn't re-navigate
    emit(ChatListLoaded(_currentChats));
  }

  void _onUnsubscribed(
      ChatListUnsubscribed event, Emitter<ChatListState> emit) {
    _chatsSub?.cancel();
    _currentChats = [];
    emit(ChatListInitial());
  }

  @override
  Future<void> close() {
    _chatsSub?.cancel();
    return super.close();
  }
}
