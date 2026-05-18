// CHAT DETAIL SCREEN
// -----------------------------------------------------------------------------
// WhatsApp-style chat view. Header with name + online status, scrollable
// message bubbles, input row at bottom.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/data/chat_models.dart';
import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const Color _chatAccent = Color(0xFF1FA088);

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(widget.chatId, text);
    _inputCtrl.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'offline';
    final diff = DateTime.now().difference(lastSeen);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, chatProvider, __) {
        final chat = chatProvider.chatById(widget.chatId);
        if (chat == null) {
          return const Scaffold(
            backgroundColor: AppColors.lightBg,
            body: Center(child: Text('Chat not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.lightBg,
          appBar: _ChatHeader(
            chat: chat,
            accent: _chatAccent,
            formatLastSeen: _formatLastSeen,
          ),
          body: Column(
            children: [
              Expanded(
                child: chat.messages.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        itemCount: chat.messages.length,
                        itemBuilder: (_, i) {
                          final m = chat.messages[i];
                          final prevSender = i > 0
                              ? chat.messages[i - 1].senderId
                              : null;
                          final showTail = prevSender != m.senderId;
                          return _MessageBubble(
                            message: m,
                            showTail: showTail,
                            accent: _chatAccent,
                          );
                        },
                      ),
              ),
              _InputRow(
                controller: _inputCtrl,
                accent: _chatAccent,
                onSend: _sendMessage,
                onTextChanged: () => setState(() {}),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final Chat chat;
  final Color accent;
  final String Function(DateTime?) formatLastSeen;

  const _ChatHeader({
    required this.chat,
    required this.accent,
    required this.formatLastSeen,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBg,
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
      shadowColor: AppColors.lightBorder,
      leadingWidth: 32,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        color: AppColors.lightTextPrimary,
        padding: EdgeInsets.zero,
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chat.isSelfChat
                  ? accent.withOpacity(0.15)
                  : AppColors.lightElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: chat.isSelfChat
                    ? accent.withOpacity(0.3)
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: chat.isSelfChat
                ? Icon(Icons.bookmark_rounded, color: accent, size: 18)
                : Text(
                    chat.user.initials,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  chat.isSelfChat ? 'Notes to self' : chat.user.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!chat.isSelfChat)
                  Text(
                    chat.user.isOnline
                        ? 'online'
                        : 'last seen ${formatLastSeen(chat.user.lastSeen)}',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      color: chat.user.isOnline
                          ? accent
                          : AppColors.lightTextTertiary,
                      fontWeight: chat.user.isOnline
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.videocam_outlined, size: 22),
          color: AppColors.lightTextSecondary,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call_outlined, size: 20),
          color: AppColors.lightTextSecondary,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          color: AppColors.lightTextSecondary,
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTail;
  final Color accent;

  const _MessageBubble({
    required this.message,
    required this.showTail,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    final bgColor = isMine ? accent.withOpacity(0.95) : AppColors.lightSurface;
    final textColor = isMine ? Colors.white : AppColors.lightTextPrimary;
    final timeColor =
        isMine ? Colors.white.withOpacity(0.7) : AppColors.lightTextTertiary;

    final radius = isMine
        ? BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: showTail ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          )
        : BorderRadius.only(
            topLeft: showTail ? const Radius.circular(4) : const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          );

    return Padding(
      padding: EdgeInsets.only(
        top: showTail ? 8 : 2,
        bottom: 2,
        left: isMine ? 60 : 0,
        right: isMine ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: radius,
                border: isMine
                    ? null
                    : Border.all(
                        color: AppColors.lightBorder,
                        width: 0.5,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: textColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          color: timeColor,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        _StatusIcon(status: message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final mm = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$mm $ampm';
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withOpacity(0.8);
    switch (status) {
      case MessageStatus.sending:
        return Icon(Icons.access_time_rounded, size: 11, color: color);
      case MessageStatus.sent:
        return Icon(Icons.check_rounded, size: 12, color: color);
      case MessageStatus.delivered:
        return Icon(Icons.done_all_rounded, size: 13, color: color);
      case MessageStatus.read:
        return const Icon(Icons.done_all_rounded, size: 13, color: Colors.white);
    }
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final Color accent;
  final VoidCallback onSend;
  final VoidCallback onTextChanged;

  const _InputRow({
    required this.controller,
    required this.accent,
    required this.onSend,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.lightBg,
        border: Border(
          top: BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.lightBorder, width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLines: 5,
                        minLines: 1,
                        cursorColor: accent,
                        textInputAction: TextInputAction.newline,
                        onChanged: (_) => onTextChanged(),
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: AppColors.lightTextPrimary,
                          height: 1.3,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 6),
                      child: Icon(
                        Icons.attach_file_rounded,
                        size: 20,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: hasText ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: hasText ? accent : AppColors.lightElevated,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasText ? Icons.send_rounded : Icons.mic_rounded,
                  color: hasText ? Colors.white : AppColors.lightTextSecondary,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40,
            color: AppColors.lightTextTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Say hi to get the conversation going',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              color: AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}