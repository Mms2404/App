// CHAT MODELS — Firebase edition
// -----------------------------------------------------------------------------
// Firestore structure:
//   users/{phone}            → ChatUser
//   chats/{chatId}           → Chat metadata
//   chats/{chatId}/messages/ → Message subcollection
// -----------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/features/chat/domain/entities/chat_entities.dart' as entity;

class ChatUser {
  final String phone; // document ID + senderId
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatUser({
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

  factory ChatUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatUser(
      phone: doc.id,
      name: d['name'] as String? ?? doc.id,
      avatarUrl: d['avatarUrl'] as String?,
      isOnline: d['isOnline'] as bool? ?? false,
      lastSeen: (d['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'isOnline': isOnline,
        'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      };
}

enum MessageStatus { sending, sent, delivered, read }

enum MessageType { text, image }

class Message {
  final String id;
  final String chatId;
  final String senderId; // phone of sender
  final String text;
  final MessageType type;
  final String? imageUrl; // for image messages (UI only for now)
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToId;   // id of message being replied to
  final String? replyToText; // cached preview of replied message
  final bool isDeleted;

  const Message({
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

  factory Message.fromDoc(DocumentSnapshot doc, String chatId) {
    final d = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      chatId: chatId,
      senderId: d['senderId'] as String,
      text: d['text'] as String? ?? '',
      type: d['type'] == 'image' ? MessageType.image : MessageType.text,
      imageUrl: d['imageUrl'] as String?,
      timestamp: (d['timestamp'] as Timestamp).toDate(),
      status: _statusFrom(d['status'] as String?),
      replyToId: d['replyToId'] as String?,
      replyToText: d['replyToText'] as String?,
      isDeleted: d['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'text': text,
        'type': type == MessageType.image ? 'image' : 'text',
        if (imageUrl != null) 'imageUrl': imageUrl,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': status.name,
        if (replyToId != null) 'replyToId': replyToId,
        if (replyToText != null) 'replyToText': replyToText,
        'isDeleted': isDeleted,
      };

  Message copyWith({
    MessageStatus? status,
    bool? isDeleted,
    String? text,
  }) =>
      Message(
        id: id,
        chatId: chatId,
        senderId: senderId,
        text: text ?? this.text,
        type: type,
        imageUrl: imageUrl,
        timestamp: timestamp,
        status: status ?? this.status,
        replyToId: replyToId,
        replyToText: replyToText,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  static MessageStatus _statusFrom(String? s) {
    switch (s) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      default:
        return MessageStatus.sent;
    }
  }
}

class Chat {
  final String id; // "{phone1}_{phone2}" sorted
  final String otherUserPhone;
  final String otherUserName;
  final bool isSelfChat;
  final String lastMessageText;
  final DateTime? lastMessageTime;
  final bool lastMessageIsMine;
  final int unreadCount;

  const Chat({
    required this.id,
    required this.otherUserPhone,
    required this.otherUserName,
    this.isSelfChat = false,
    this.lastMessageText = '',
    this.lastMessageTime,
    this.lastMessageIsMine = false,
    this.unreadCount = 0,
  });

  String get displayName =>
      isSelfChat ? 'Notes to self' : otherUserName;

  String get initials {
    final parts = otherUserName.trim().split(' ');
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory Chat.fromDoc(DocumentSnapshot doc, String myPhone) {
    final d = doc.data() as Map<String, dynamic>;
    final participants = List<String>.from(d['participants'] as List);
    final other =
        participants.firstWhere((p) => p != myPhone, orElse: () => myPhone);
    final names = Map<String, String>.from(d['participantNames'] as Map? ?? {});
    final unreadCounts =
        Map<String, dynamic>.from(d['unreadCounts'] as Map? ?? {});

    return Chat(
      id: doc.id,
      otherUserPhone: other,
      otherUserName: names[other] ?? other,
      isSelfChat: other == myPhone,
      lastMessageText: d['lastMessageText'] as String? ?? '',
      lastMessageTime: (d['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageIsMine: d['lastMessageSender'] == myPhone,
      unreadCount: (unreadCounts[myPhone] as int?) ?? 0,
    );
  }
}

// ── Entity mappers (data → domain) ───────────────────────────────────────────
// Added for Clean Architecture. Models map themselves to domain entities.
// Repository calls these; domain layer stays Firebase-free.


extension ChatUserMapper on ChatUser {
  entity.ChatUserEntity toEntity() => entity.ChatUserEntity(
        phone: phone,
        name: name,
        avatarUrl: avatarUrl,
        isOnline: isOnline,
        lastSeen: lastSeen,
      );
}

extension MessageMapper on Message {
  entity.MessageEntity toEntity() => entity.MessageEntity(
        id: id,
        chatId: chatId,
        senderId: senderId,
        text: text,
        type: type == MessageType.image
            ? entity.MessageType.image
            : entity.MessageType.text,
        imageUrl: imageUrl,
        timestamp: timestamp,
        status: _mapStatus(status),
        replyToId: replyToId,
        replyToText: replyToText,
        isDeleted: isDeleted,
      );

  entity.MessageStatus _mapStatus(MessageStatus s) {
    switch (s) {
      case MessageStatus.sending:   return entity.MessageStatus.sending;
      case MessageStatus.delivered: return entity.MessageStatus.delivered;
      case MessageStatus.read:      return entity.MessageStatus.read;
      default:                      return entity.MessageStatus.sent;
    }
  }
}

extension ChatMapper on Chat {
  entity.ChatEntity toEntity() => entity.ChatEntity(
        id: id,
        otherUserPhone: otherUserPhone,
        otherUserName: otherUserName,
        isSelfChat: isSelfChat,
        lastMessageText: lastMessageText,
        lastMessageTime: lastMessageTime,
        lastMessageIsMine: lastMessageIsMine,
        unreadCount: unreadCount,
      );
}
