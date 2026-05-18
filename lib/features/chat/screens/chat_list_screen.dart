// CHAT LIST SCREEN
// -----------------------------------------------------------------------------
// WhatsApp-style chat list. Pinned "Notes to self" first, then other threads
// sorted by most-recent message.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/data/chat_models.dart';
import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:app/features/chat/screens/chat_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const Color _chatAccent = Color(0xFF1FA088);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
    onPressed: () => context.read<ChatProvider>().logout(),
    icon: const Icon(
      Icons.arrow_left_rounded,
      color: AppColors.lightTextSecondary,
      size: 42,
    ),
  ),
        title: const Text(
          'Chats',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search_rounded,
                color: AppColors.lightTextSecondary, size: 22),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.lightTextSecondary, size: 22),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (_, chatProvider, __) {
          final chats = chatProvider.chats;
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No chats yet',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.lightTextSecondary,
                ),
              ),
            );
          }

          // Self chat pinned first, others sorted by last message timestamp
          final pinned = chats.where((c) => c.isSelfChat).toList();
          final others = chats.where((c) => !c.isSelfChat).toList()
            ..sort((a, b) {
              final aTime = a.lastMessage?.timestamp ?? DateTime(0);
              final bTime = b.lastMessage?.timestamp ?? DateTime(0);
              return bTime.compareTo(aTime);
            });

          final ordered = [...pinned, ...others];

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: ordered.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(left: 80),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.lightBorder,
              ),
            ),
            itemBuilder: (_, i) => _ChatTile(
              chat: ordered[i],
              accent: _chatAccent,
              onTap: () {
                chatProvider.markChatAsRead(ordered[i].id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider<ChatProvider>.value(
                      value: chatProvider,
                      child: ChatDetailScreen(chatId: ordered[i].id)  
                      )
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _chatAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.edit_rounded, size: 20),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final Color accent;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = chat.lastMessage;
    final hasUnread = chat.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _Avatar(user: chat.user, isSelfChat: chat.isSelfChat, accent: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.isSelfChat ? 'Notes to self' : chat.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      if (lastMessage != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(lastMessage.timestamp),
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: hasUnread
                                ? accent
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (lastMessage?.isMine == true) ...[
                        _StatusIcon(status: lastMessage!.status, accent: accent),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          lastMessage?.text ?? 'No messages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: hasUnread
                                ? AppColors.lightTextPrimary
                                : AppColors.lightTextSecondary,
                            fontWeight:
                                hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final isToday = t.year == now.year && t.month == now.month && t.day == now.day;
    if (isToday) {
      final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
      final mm = t.minute.toString().padLeft(2, '0');
      final ampm = t.hour >= 12 ? 'PM' : 'AM';
      return '$h:$mm $ampm';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        t.year == yesterday.year && t.month == yesterday.month && t.day == yesterday.day;
    if (isYesterday) return 'Yesterday';
    return '${t.day}/${t.month}/${t.year % 100}';
  }
}

class _Avatar extends StatelessWidget {
  final ChatUser user;
  final bool isSelfChat;
  final Color accent;

  const _Avatar({
    required this.user,
    required this.isSelfChat,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isSelfChat ? accent.withOpacity(0.15) : AppColors.lightElevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelfChat ? accent.withOpacity(0.3) : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: isSelfChat
              ? Icon(Icons.bookmark_rounded, color: accent, size: 22)
              : Text(
                  user.initials,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
        ),
        if (!isSelfChat && user.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightBg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  final Color accent;
  const _StatusIcon({required this.status, required this.accent});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time_rounded,
          size: 12,
          color: AppColors.lightTextTertiary,
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check_rounded,
          size: 13,
          color: AppColors.lightTextTertiary,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all_rounded,
          size: 14,
          color: AppColors.lightTextTertiary,
        );
      case MessageStatus.read:
        return Icon(Icons.done_all_rounded, size: 14, color: accent);
    }
  }
}