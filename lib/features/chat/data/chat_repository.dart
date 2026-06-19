// CHAT REPOSITORY — Clean Architecture edition
// -----------------------------------------------------------------------------
// All Firebase/Firestore calls live here. Returns domain entities, not raw
// Firestore types. Use cases call this. Blocs never touch Firebase directly.
//
// Also owns Firebase Auth operations so the auth layer stays in data/ only.
// -----------------------------------------------------------------------------

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/features/chat/data/chat_models.dart';
import 'package:app/features/chat/domain/entities/chat_entities.dart';

class ChatRepository {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ChatRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db   = db   ?? FirebaseFirestore.instance,
        _auth  = auth ?? FirebaseAuth.instance;

  // ── Collections ───────────────────────────────────────────────────────────
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _chats => _db.collection('chats');
  CollectionReference _messages(String chatId) =>
      _chats.doc(chatId).collection('messages');

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Sends OTP. Throws on network/validation errors.
  Future<void> sendOtp(String phone) async {
    final e164 = phone.startsWith('+') ? phone : '+91$phone';
    final completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: e164,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (cred) async {
        // Android auto-retrieval — complete immediately
        if (!completer.isCompleted) completer.complete();
      },
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, _) {
        // Store verificationId on the completer's value via a side-channel.
        // AuthBloc will call verifyOtp() which reads it from a separate call.
        _lastVerificationId = verificationId;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  // Last verification ID stored between sendOtp and verifyOtp calls.
  String? _lastVerificationId;

  /// Verifies OTP. Returns AuthResult (success or failure).
  Future<AuthResult> verifyOtp(
      String otp, String verificationId, String name) async {
    try {
      final vid = verificationId.isNotEmpty
          ? verificationId
          : (_lastVerificationId ?? '');
      final cred = PhoneAuthProvider.credential(
          verificationId: vid, smsCode: otp);
      final result = await _auth.signInWithCredential(cred);
      final user   = result.user!;
      final phone  = user.phoneNumber!.replaceAll('+', '');

      if (name.isNotEmpty) await user.updateDisplayName(name);

      await _upsertUser(phone, name.isNotEmpty ? name : phone);
      return AuthResult.success(phone: phone, name: name.isNotEmpty ? name : phone);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e));
    } catch (e) {
      return AuthResult.failure('Authentication failed.');
    }
  }

  String get lastVerificationId => _lastVerificationId ?? '';

  /// Restore existing Firebase session.
  Future<({String phone, String name})?> restoreSession() async {
    final user = _auth.currentUser;
    if (user?.phoneNumber == null) return null;
    final phone = user!.phoneNumber!.replaceAll('+', '');
    final name  = user.displayName ?? phone;
    await _upsertUser(phone, name);
    return (phone: phone, name: name);
  }

  /// Sign out + set offline.
  Future<void> logout(String phone) async {
    await setOnline(phone, false);
    await _auth.signOut();
    _lastVerificationId = null;
  }

  // ── User ──────────────────────────────────────────────────────────────────

  Future<void> _upsertUser(String phone, String name) async {
    await _users.doc(phone).set({
      'phone': phone,
      'name': name,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setOnline(String phone, bool online) async {
    await _users.doc(phone).update({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Stream<ChatUserEntity?> userStream(String phone) {
    return _users.doc(phone).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatUser.fromDoc(doc).toEntity();
    });
  }

  Future<List<ChatUserEntity>> searchUsers(String query, String myPhone) async {
    final snap = await _users
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(20)
        .get();
    return snap.docs
        .map((d) => ChatUser.fromDoc(d).toEntity())
        .where((u) => u.phone != myPhone)
        .toList();
  }

  // ── Chat list ─────────────────────────────────────────────────────────────

  Stream<List<ChatEntity>> chatsStream(String myPhone) {
    return _chats
        .where('participants', arrayContains: myPhone)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Chat.fromDoc(d, myPhone).toEntity())
            .toList());
  }

  Future<String> openOrCreateChat({
    required String myPhone,
    required String myName,
    required String otherPhone,
    required String otherName,
  }) async {
    final sorted = [myPhone, otherPhone]..sort();
    final chatId = sorted.join('_');
    final doc    = _chats.doc(chatId);
    final snap   = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'participants': sorted,
        'participantNames': {myPhone: myName, otherPhone: otherName},
        'lastMessageText': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': '',
        'unreadCounts': {myPhone: 0, otherPhone: 0},
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Stream<List<MessageEntity>> messagesStream(String chatId) {
    return _messages(chatId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Message.fromDoc(d, chatId).toEntity())
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String myPhone,
    required String otherPhone,
    required String text,
    String? imageUrl,
    String? replyToId,
    String? replyToText,
  }) async {
    final msgRef = _messages(chatId).doc();
    final now    = FieldValue.serverTimestamp();

    // Build map directly — avoids MessageType/MessageStatus model vs entity clash.
    final msgData = <String, dynamic>{
      'senderId':  myPhone,
      'text':      text,
      'type':      imageUrl != null ? 'image' : 'text',
      if (imageUrl != null) 'imageUrl': imageUrl,
      'timestamp': now,
      'status':    'sent',
      if (replyToId   != null) 'replyToId':   replyToId,
      if (replyToText != null) 'replyToText': replyToText,
      'isDeleted': false,
    };

    final batch = _db.batch();
    batch.set(msgRef, msgData);
    batch.update(_chats.doc(chatId), {
      'lastMessageText':   imageUrl != null ? '📷 Photo' : text,
      'lastMessageTime':   now,
      'lastMessageSender': myPhone,
      'unreadCounts.$otherPhone': FieldValue.increment(1),
    });
    await batch.commit();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _messages(chatId).doc(messageId).update({'isDeleted': true, 'text': ''});
  }

  Future<void> markAsRead(String chatId, String myPhone) async {
    await _chats.doc(chatId).update({'unreadCounts.$myPhone': 0});
    final unread = await _messages(chatId)
        .where('senderId', isNotEqualTo: myPhone)
        .where('status', isNotEqualTo: 'read')
        .get();
    final batch = _db.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'status': 'read'});
    }
    await batch.commit();
  }

  // ── Error mapping ─────────────────────────────────────────────────────────
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':    return 'Invalid phone number format.';
      case 'too-many-requests':       return 'Too many attempts. Try again later.';
      case 'invalid-verification-code': return 'Wrong OTP. Check and try again.';
      case 'session-expired':         return 'OTP expired. Request a new one.';
      case 'network-request-failed':  return 'No internet connection.';
      default: return e.message ?? 'Authentication failed.';
    }
  }
}
