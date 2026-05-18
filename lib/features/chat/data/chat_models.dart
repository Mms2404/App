// CHAT MODELS
// -----------------------------------------------------------------------------
// Plain Dart classes for chat data. No Freezed — keeping this feature simple
// like the shop. Models are immutable (final fields) but no codegen.
// -----------------------------------------------------------------------------

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

enum MessageStatus {
  sending,   // Single empty circle
  sent,      // Single check
  delivered, // Double check (gray)
  read,      // Double check (accent)
}

class Message {
  final String id;
  final String chatId;
  final String senderId;      // 'me' for sent, user id for received
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.read,
  });

  bool get isMine => senderId == 'me';
}

class Chat {
  final String id;
  final ChatUser user;
  final List<Message> messages;
  final bool isSelfChat;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.user,
    required this.messages,
    this.isSelfChat = false,
    this.unreadCount = 0,
  });

  Message? get lastMessage => messages.isEmpty ? null : messages.last;
}