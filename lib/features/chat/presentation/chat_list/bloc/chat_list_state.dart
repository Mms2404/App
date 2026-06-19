part of 'chat_list_bloc.dart';

abstract class ChatListState {}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatEntity> chats;
  ChatListLoaded(this.chats);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}

/// Search results ready
class ContactSearchResults extends ChatListState {
  final List<ChatUserEntity> users;
  final List<ChatEntity> chats; // keep current list visible behind search
  ContactSearchResults({required this.users, required this.chats});
}

/// A chat was opened — carries chatId for navigation
class ChatNavigateToMessages extends ChatListState {
  final String chatId;
  final String otherPhone;
  final List<ChatEntity> chats;
  ChatNavigateToMessages({
    required this.chatId,
    required this.otherPhone,
    required this.chats,
  });
}
