// CHAT PROVIDER
// -----------------------------------------------------------------------------
// ChangeNotifier (Provider pattern, same as the shop app's CartModel).
// Owns the list of chats and exposes methods to send messages and mark as read.
// -----------------------------------------------------------------------------

import 'package:app/features/chat/data/chat_models.dart';
import 'package:app/features/chat/data/chat_seed.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  List<Chat> _chats = [];
  String? _currentUserPhone;

  List<Chat> get chats => List.unmodifiable(_chats);
  String? get currentUserPhone => _currentUserPhone;

  /// Call after OTP verification. Loads seed data.
  void login(String phone) {
    _currentUserPhone = phone;
    _chats = ChatSeed.generate();
    notifyListeners();
  }

  void logout() {
    _currentUserPhone = null;
    _chats = [];
    notifyListeners();
  }

  Chat? chatById(String id) {
    try {
      return _chats.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void sendMessage(String chatId, String text) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex < 0) return;

    final chat = _chats[chatIndex];
    final newMessage = Message(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'me',
      text: text,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    _chats[chatIndex] = Chat(
      id: chat.id,
      user: chat.user,
      isSelfChat: chat.isSelfChat,
      unreadCount: chat.unreadCount,
      messages: [...chat.messages, newMessage],
    );
    notifyListeners();

    // Simulate sending → sent → delivered → read
    _simulateMessageStatusProgression(chatId, newMessage.id);
  }

  void _simulateMessageStatusProgression(String chatId, String messageId) {
    Future.delayed(const Duration(milliseconds: 400), () {
      _updateMessageStatus(chatId, messageId, MessageStatus.sent);
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      _updateMessageStatus(chatId, messageId, MessageStatus.delivered);
    });
    Future.delayed(const Duration(seconds: 3), () {
      _updateMessageStatus(chatId, messageId, MessageStatus.read);
    });
  }

  void _updateMessageStatus(
      String chatId, String messageId, MessageStatus status) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex < 0) return;

    final chat = _chats[chatIndex];
    final newMessages = chat.messages.map((m) {
      if (m.id != messageId) return m;
      return Message(
        id: m.id,
        chatId: m.chatId,
        senderId: m.senderId,
        text: m.text,
        timestamp: m.timestamp,
        status: status,
      );
    }).toList();

    _chats[chatIndex] = Chat(
      id: chat.id,
      user: chat.user,
      isSelfChat: chat.isSelfChat,
      unreadCount: chat.unreadCount,
      messages: newMessages,
    );
    notifyListeners();
  }

  void markChatAsRead(String chatId) {
    final chatIndex = _chats.indexWhere((c) => c.id == chatId);
    if (chatIndex < 0) return;

    final chat = _chats[chatIndex];
    if (chat.unreadCount == 0) return;

    _chats[chatIndex] = Chat(
      id: chat.id,
      user: chat.user,
      isSelfChat: chat.isSelfChat,
      unreadCount: 0,
      messages: chat.messages,
    );
    notifyListeners();
  }
}