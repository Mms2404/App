// CHAT SEED
// -----------------------------------------------------------------------------
// Hardcoded fake data so the UI has something to show. Replace with real
// backend data later — this file gets deleted when the API is wired up.
// -----------------------------------------------------------------------------

import 'chat_models.dart';

class ChatSeed {
  static List<Chat> generate() {
    final now = DateTime.now();

    return [
      // Self chat — pinned at top
      Chat(
        id: 'self',
        isSelfChat: true,
        user: const ChatUser(
          id: 'me',
          name: 'Notes to self',
        ),
        messages: [
          Message(
            id: 'self_1',
            chatId: 'self',
            senderId: 'me',
            text: 'Remember to push the chat feature commit before end of day',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          Message(
            id: 'self_2',
            chatId: 'self',
            senderId: 'me',
            text: 'Coffee meeting tomorrow at 11',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      Chat(
        id: 'chat_1',
        user: ChatUser(
          id: 'user_1',
          name: 'Aravind Menon',
          isOnline: true,
        ),
        unreadCount: 2,
        messages: [
          Message(
            id: 'm1',
            chatId: 'chat_1',
            senderId: 'user_1',
            text: 'Hey, how\'s the Flutter project going?',
            timestamp: now.subtract(const Duration(minutes: 45)),
          ),
          Message(
            id: 'm2',
            chatId: 'chat_1',
            senderId: 'me',
            text: 'Almost done with the chat feature now',
            timestamp: now.subtract(const Duration(minutes: 30)),
            status: MessageStatus.read,
          ),
          Message(
            id: 'm3',
            chatId: 'chat_1',
            senderId: 'user_1',
            text: 'Nice. Can you send the design when ready?',
            timestamp: now.subtract(const Duration(minutes: 10)),
          ),
          Message(
            id: 'm4',
            chatId: 'chat_1',
            senderId: 'user_1',
            text: 'I want to show it to the team',
            timestamp: now.subtract(const Duration(minutes: 9)),
          ),
        ],
      ),
      Chat(
        id: 'chat_2',
        user: ChatUser(
          id: 'user_2',
          name: 'Priya Sharma',
          isOnline: false,
          lastSeen: now.subtract(const Duration(hours: 3)),
        ),
        messages: [
          Message(
            id: 'm5',
            chatId: 'chat_2',
            senderId: 'me',
            text: 'Did you check the PR?',
            timestamp: now.subtract(const Duration(hours: 5)),
            status: MessageStatus.delivered,
          ),
        ],
      ),
      Chat(
        id: 'chat_3',
        user: ChatUser(
          id: 'user_3',
          name: 'Rahul K',
          isOnline: true,
        ),
        messages: [
          Message(
            id: 'm6',
            chatId: 'chat_3',
            senderId: 'user_3',
            text: 'Lunch tomorrow?',
            timestamp: now.subtract(const Duration(days: 1)),
          ),
          Message(
            id: 'm7',
            chatId: 'chat_3',
            senderId: 'me',
            text: 'Yeah, 1pm at the usual spot',
            timestamp: now.subtract(const Duration(days: 1)),
            status: MessageStatus.read,
          ),
        ],
      ),
      Chat(
        id: 'chat_4',
        user: ChatUser(
          id: 'user_4',
          name: 'Devika',
          isOnline: false,
          lastSeen: now.subtract(const Duration(days: 2)),
        ),
        messages: [
          Message(
            id: 'm8',
            chatId: 'chat_4',
            senderId: 'user_4',
            text: 'Happy birthday! Hope you have a great year ahead',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
        ],
      ),
    ];
  }
}