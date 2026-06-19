part of 'chat_list_bloc.dart';

abstract class ChatListEvent {}

/// Start listening to the chats stream for this user
class ChatListSubscribed extends ChatListEvent {
  final String myPhone;
  ChatListSubscribed(this.myPhone);
}

/// Internal — stream emitted a new list
class _ChatsUpdated extends ChatListEvent {
  final List<ChatEntity> chats;
  _ChatsUpdated(this.chats);
}

/// User tapped the FAB — search contacts
class UserSearched extends ChatListEvent {
  final String query;
  final String myPhone;
  UserSearched({required this.query, required this.myPhone});
}

/// User picked a contact → open or create chat
class ChatOpened extends ChatListEvent {
  final String myPhone;
  final String myName;
  final String otherPhone;
  final String otherName;
  ChatOpened({
    required this.myPhone,
    required this.myName,
    required this.otherPhone,
    required this.otherName,
  });
}

/// Stop listening (user logged out)
class ChatListUnsubscribed extends ChatListEvent {}
