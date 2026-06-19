// CHAT USE CASES
// -----------------------------------------------------------------------------
// One class per use case. Each wraps exactly one repository call.
// Blocs depend on use cases, never directly on the repository.
//
// Why use cases even when thin?
//   • Single responsibility — easy to unit test in isolation
//   • If repository changes (e.g. Firestore → REST), only use cases change
//   • Bloc stays clean — it orchestrates, not implements
// -----------------------------------------------------------------------------

import 'package:app/features/chat/data/chat_repository.dart';
import 'package:app/features/chat/domain/entities/chat_entities.dart';

// ── Auth use cases ────────────────────────────────────────────────────────────

class SendOtpUseCase {
  final ChatRepository _repo;
  SendOtpUseCase(this._repo);

  Future<void> call(String phone) => _repo.sendOtp(phone);
}

class VerifyOtpUseCase {
  final ChatRepository _repo;
  VerifyOtpUseCase(this._repo);

  Future<AuthResult> call(String otp, String verificationId, String name) =>
      _repo.verifyOtp(otp, verificationId, name);
}

class LogoutUseCase {
  final ChatRepository _repo;
  LogoutUseCase(this._repo);

  Future<void> call(String phone) => _repo.logout(phone);
}

class RestoreSessionUseCase {
  final ChatRepository _repo;
  RestoreSessionUseCase(this._repo);

  // Returns (phone, name) if a session exists, null otherwise
  Future<({String phone, String name})?> call() => _repo.restoreSession();
}

// ── Chat list use cases ───────────────────────────────────────────────────────

class WatchChatsUseCase {
  final ChatRepository _repo;
  WatchChatsUseCase(this._repo);

  Stream<List<ChatEntity>> call(String myPhone) => _repo.chatsStream(myPhone);
}

class OpenOrCreateChatUseCase {
  final ChatRepository _repo;
  OpenOrCreateChatUseCase(this._repo);

  Future<String> call({
    required String myPhone,
    required String myName,
    required String otherPhone,
    required String otherName,
  }) =>
      _repo.openOrCreateChat(
        myPhone: myPhone,
        myName: myName,
        otherPhone: otherPhone,
        otherName: otherName,
      );
}

class SearchUsersUseCase {
  final ChatRepository _repo;
  SearchUsersUseCase(this._repo);

  Future<List<ChatUserEntity>> call(String query, String myPhone) =>
      _repo.searchUsers(query, myPhone);
}

// ── Message use cases ─────────────────────────────────────────────────────────

class WatchMessagesUseCase {
  final ChatRepository _repo;
  WatchMessagesUseCase(this._repo);

  Stream<List<MessageEntity>> call(String chatId) =>
      _repo.messagesStream(chatId);
}

class SendMessageUseCase {
  final ChatRepository _repo;
  SendMessageUseCase(this._repo);

  Future<void> call({
    required String chatId,
    required String myPhone,
    required String otherPhone,
    required String text,
    String? imageUrl,
    String? replyToId,
    String? replyToText,
  }) =>
      _repo.sendMessage(
        chatId: chatId,
        myPhone: myPhone,
        otherPhone: otherPhone,
        text: text,
        imageUrl: imageUrl,
        replyToId: replyToId,
        replyToText: replyToText,
      );
}

class DeleteMessageUseCase {
  final ChatRepository _repo;
  DeleteMessageUseCase(this._repo);

  Future<void> call(String chatId, String messageId) =>
      _repo.deleteMessage(chatId, messageId);
}

class MarkAsReadUseCase {
  final ChatRepository _repo;
  MarkAsReadUseCase(this._repo);

  Future<void> call(String chatId, String myPhone) =>
      _repo.markAsRead(chatId, myPhone);
}

class WatchUserUseCase {
  final ChatRepository _repo;
  WatchUserUseCase(this._repo);

  Stream<ChatUserEntity?> call(String phone) => _repo.userStream(phone);
}
