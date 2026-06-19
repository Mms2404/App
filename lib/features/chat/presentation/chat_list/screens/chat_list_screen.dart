import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/domain/entities/chat_entities.dart';
import 'package:app/features/chat/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/features/chat/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:app/features/chat/presentation/messages/bloc/messages_bloc.dart';
import 'package:app/features/chat/presentation/messages/screens/chat_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _accent = Color(0xFF1FA088);

class ChatListScreen extends StatelessWidget {
  final ValueChanged<bool> onChromeOverride;
  const ChatListScreen({super.key, required this.onChromeOverride});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatListBloc, ChatListState>(
      listenWhen: (_, s) => s is ChatNavigateToMessages,
      listener: (context, state) {
        if (state is ChatNavigateToMessages) {
          onChromeOverride(false);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<MessagesBloc>()),
                BlocProvider.value(value: context.read<AuthBloc>()),
              ],
              child: ChatDetailScreen(
                chatId:     state.chatId,
                otherPhone: state.otherPhone,
              ),
            ),
          )).then((_) => onChromeOverride(true));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: AppColors.lightBg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
            icon: const Icon(Icons.arrow_left_rounded,
                color: AppColors.lightTextSecondary, size: 42),
          ),
          title: const Text('Chats',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 22,
                  fontWeight: FontWeight.w700, color: AppColors.lightTextPrimary,
                  letterSpacing: -0.3)),
          actions: [
            IconButton(onPressed: () {},
                icon: const Icon(Icons.search_rounded, color: AppColors.lightTextSecondary, size: 22)),
            IconButton(onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.lightTextSecondary, size: 22)),
          ],
        ),
        body: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return const Center(child: CircularProgressIndicator(color: _accent, strokeWidth: 2));
            }
            if (state is ChatListError) {
              return Center(child: Text(state.message,
                  style: const TextStyle(fontFamily: 'Manrope', color: AppColors.lightTextSecondary)));
            }
            final chats = state is ChatListLoaded   ? state.chats
                        : state is ContactSearchResults ? state.chats
                        : <ChatEntity>[];
            if (chats.isEmpty) {
              return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.lightTextTertiary),
                SizedBox(height: 12),
                Text('No chats yet', style: TextStyle(fontFamily: 'Manrope', fontSize: 14,
                    color: AppColors.lightTextSecondary)),
                SizedBox(height: 4),
                Text('Tap the pencil icon to start one',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: AppColors.lightTextTertiary)),
              ]));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(left: 80),
                child: Divider(height: 1, thickness: 0.5, color: AppColors.lightBorder),
              ),
              itemBuilder: (_, i) {
                final chat = chats[i];
                final authState = context.read<AuthBloc>().state as AuthAuthenticated;
                return _ChatTile(
                  chat: chat,
                  onTap: () => context.read<ChatListBloc>().add(ChatOpened(
                    myPhone:    authState.phone,
                    myName:     authState.name,
                    otherPhone: chat.otherUserPhone,
                    otherName:  chat.otherUserName,
                  )),
                );
              },
            );
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        //     builder: (_) => MultiBlocProvider(
        //       providers: [
        //         BlocProvider.value(value: context.read<ChatListBloc>()),
        //         BlocProvider.value(value: context.read<AuthBloc>()),
        //       ],
        //       child: const NewChatScreen(),
        //     ),
        //   )),
        //   backgroundColor: _accent,
        //   foregroundColor: Colors.white,
        //   elevation: 2,
        //   child: const Icon(Icons.edit_rounded, size: 20),
        // ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: chat.isSelfChat ? _accent.withOpacity(0.15) : AppColors.lightElevated,
              shape: BoxShape.circle,
              border: Border.all(
                  color: chat.isSelfChat ? _accent.withOpacity(0.3) : AppColors.lightBorder, width: 0.5),
            ),
            alignment: Alignment.center,
            child: chat.isSelfChat
                ? const Icon(Icons.bookmark_rounded, color: _accent, size: 22)
                : Text(chat.initials, style: const TextStyle(fontFamily: 'Manrope', fontSize: 16,
                    fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(chat.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: 'Manrope', fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.lightTextPrimary))),
              if (chat.lastMessageTime != null) ...[
                const SizedBox(width: 8),
                Text(_formatTime(chat.lastMessageTime!),
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 11,
                        color: hasUnread ? _accent : AppColors.lightTextTertiary,
                        fontWeight: FontWeight.w500)),
              ],
            ]),
            const SizedBox(height: 4),
            Row(children: [
              if (chat.lastMessageIsMine) ...[
                const Icon(Icons.done_all_rounded, size: 14, color: _accent),
                const SizedBox(width: 4),
              ],
              Expanded(child: Text(
                chat.lastMessageText.isEmpty ? 'No messages yet' : chat.lastMessageText,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: 'Manrope', fontSize: 13,
                    color: hasUnread ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400))),
              if (hasUnread) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(10)),
                  child: Text('${chat.unreadCount}', style: const TextStyle(fontFamily: 'Manrope',
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ],
            ]),
          ])),
        ]),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));
    final date  = DateTime(t.year, t.month, t.day);
    if (date == today) {
      final h  = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
      final mm = t.minute.toString().padLeft(2, '0');
      return '$h:$mm ${t.hour >= 12 ? 'PM' : 'AM'}';
    }
    if (date == yest) return 'Yesterday';
    return '${t.day}/${t.month}/${t.year % 100}';
  }
}
