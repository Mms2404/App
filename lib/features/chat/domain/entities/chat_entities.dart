// DOMAIN ENTITIES
// -----------------------------------------------------------------------------
// Pure Dart — zero Flutter/Firebase imports. These are the app's "truth"
// objects. Data layer maps Firestore docs → these. Blocs work only with these.
// -----------------------------------------------------------------------------

enum MessageStatus { sending, sent, delivered, read }
enum MessageType   { text, image }

class ChatUserEntity {
  final String phone;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatUserEntity({
    required this.phone,
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

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final MessageType type;
  final String? imageUrl;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToId;
  final String? replyToText;
  final bool isDeleted;

  const MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    this.imageUrl,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.replyToId,
    this.replyToText,
    this.isDeleted = false,
  });

  bool isMine(String myPhone) => senderId == myPhone;
}

class ChatEntity {
  final String id;
  final String otherUserPhone;
  final String otherUserName;
  final bool isSelfChat;
  final String lastMessageText;
  final DateTime? lastMessageTime;
  final bool lastMessageIsMine;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    required this.otherUserPhone,
    required this.otherUserName,
    this.isSelfChat = false,
    this.lastMessageText = '',
    this.lastMessageTime,
    this.lastMessageIsMine = false,
    this.unreadCount = 0,
  });

  String get displayName => isSelfChat ? 'Notes to self' : otherUserName;

  String get initials {
    final parts = otherUserName.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// Result wrapper for auth operations — avoids throwing exceptions across layers
class AuthResult {
  final bool success;
  final String? error;
  final String? phone;
  final String? name;

  const AuthResult.success({required this.phone, required this.name})
      : success = true, error = null;

  const AuthResult.failure(this.error)
      : success = false, phone = null, name = null;
}
