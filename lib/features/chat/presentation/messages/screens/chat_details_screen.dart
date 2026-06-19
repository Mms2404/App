import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/domain/entities/chat_entities.dart';
import 'package:app/features/chat/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/features/chat/presentation/messages/bloc/messages_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _accent = Color(0xFF1FA088);

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherPhone;
  const ChatDetailScreen({super.key, required this.chatId, required this.otherPhone});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _inputCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;
    context.read<MessagesBloc>().add(MessagesSubscribed(
      chatId:     widget.chatId,
      myPhone:    authState.phone,
      otherPhone: widget.otherPhone,
    ));
    _inputCtrl.addListener(
        () => setState(() => _hasText = _inputCtrl.text.trim().isNotEmpty));
  }

  @override
  void dispose() {
    context.read<MessagesBloc>().add(MessagesUnsubscribed());
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(MessagesLoaded state) {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<MessagesBloc>().add(MessageSent(
      text:        text,
      replyToId:   state.replyingTo?.id,
      replyToText: state.replyingTo?.text,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myPhone = (context.read<AuthBloc>().state as AuthAuthenticated).phone;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
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
        title: Text(widget.otherPhone,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 15,
                fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        actions: [
          IconButton(onPressed: () {},
              icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.lightTextSecondary)),
        ],
      ),
      body: BlocBuilder<MessagesBloc, MessagesState>(
        builder: (context, state) {
          if (state is MessagesLoading) {
            return const Center(child: CircularProgressIndicator(color: _accent, strokeWidth: 2));
          }
          if (state is MessagesError) {
            return Center(child: Text(state.message));
          }
          if (state is! MessagesLoaded) return const SizedBox.shrink();

          _scrollToBottom();

          return Column(children: [
            Expanded(
              child: state.messages.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      itemCount: _buildItems(state.messages).length,
                      itemBuilder: (_, i) {
                        final items = _buildItems(state.messages);
                        final item  = items[i];
                        if (item is _DateSep) return _DateSepWidget(label: item.label);
                        final m    = item as MessageEntity;
                        final prev = i > 0 && items[i - 1] is MessageEntity
                            ? items[i - 1] as MessageEntity : null;
                        return _SwipeableBubble(
                          message:    m,
                          myPhone:    myPhone,
                          showTail:   prev?.senderId != m.senderId,
                          onSwipe:    () => context.read<MessagesBloc>().add(ReplySet(m)),
                          onLongPress: () => _showDeleteSheet(context, m, myPhone),
                        );
                      },
                    ),
            ),
            if (state.replyingTo != null)
              _ReplyBanner(
                message: state.replyingTo!,
                onClose: () => context.read<MessagesBloc>().add(ReplyCleared()),
              ),
            _InputRow(
              controller: _inputCtrl,
              hasText: _hasText,
              onSend: () => _send(state),
              onImageTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image upload coming soon!'),
                    behavior: SnackBarBehavior.floating)),
            ),
          ]);
        },
      ),
    );
  }

  void _showDeleteSheet(BuildContext context, MessageEntity m, String myPhone) {
    if (!m.isMine(myPhone)) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(
              color: AppColors.lightBorderStrong, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            title: const Text('Delete message', style: TextStyle(fontFamily: 'Manrope',
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.danger)),
            onTap: () {
              Navigator.pop(context);
              context.read<MessagesBloc>().add(MessageDeleted(m.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.reply_rounded, color: AppColors.lightTextSecondary),
            title: const Text('Reply', style: TextStyle(fontFamily: 'Manrope',
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
            onTap: () {
              Navigator.pop(context);
              context.read<MessagesBloc>().add(ReplySet(m));
            },
          ),
        ]),
      ),
    );
  }

  List<Object> _buildItems(List<MessageEntity> messages) {
    final items = <Object>[];
    DateTime? lastDate;
    for (final m in messages) {
      final date = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      if (lastDate == null || date != lastDate) {
        items.add(_DateSep(_labelFor(date)));
        lastDate = date;
      }
      items.add(m);
    }
    return items;
  }

  String _labelFor(DateTime date) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yest  = today.subtract(const Duration(days: 1));
    if (date == today) return 'Today';
    if (date == yest)  return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DateSep { final String label; _DateSep(this.label); }

class _DateSepWidget extends StatelessWidget {
  final String label;
  const _DateSepWidget({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider(color: AppColors.lightBorder, height: 1)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontFamily: 'Manrope',
              fontSize: 11, color: AppColors.lightTextTertiary, fontWeight: FontWeight.w500))),
        const Expanded(child: Divider(color: AppColors.lightBorder, height: 1)),
      ]),
    );
  }
}

class _SwipeableBubble extends StatefulWidget {
  final MessageEntity message;
  final String myPhone;
  final bool showTail;
  final VoidCallback onSwipe;
  final VoidCallback onLongPress;
  const _SwipeableBubble({required this.message, required this.myPhone,
      required this.showTail, required this.onSwipe, required this.onLongPress});
  @override
  State<_SwipeableBubble> createState() => _SwipeableBubbleState();
}

class _SwipeableBubbleState extends State<_SwipeableBubble> {
  double _dragX = 0;
  bool _triggered = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onHorizontalDragUpdate: (d) {
        setState(() {
          _dragX = (_dragX + d.delta.dx).clamp(-60.0, 60.0);
          if (_dragX.abs() > 40 && !_triggered) {
            _triggered = true;
            widget.onSwipe();
          }
        });
      },
      onHorizontalDragEnd: (_) => setState(() { _dragX = 0; _triggered = false; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(_dragX, 0, 0),
        child: _MessageBubble(message: widget.message,
            myPhone: widget.myPhone, showTail: widget.showTail),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final String myPhone;
  final bool showTail;
  const _MessageBubble({required this.message, required this.myPhone, required this.showTail});

  @override
  Widget build(BuildContext context) {
    final isMine  = message.isMine(myPhone);
    final deleted = message.isDeleted;
    final bgColor   = isMine ? _accent.withOpacity(0.95) : AppColors.lightSurface;
    final textColor = isMine ? Colors.white : AppColors.lightTextPrimary;
    final timeColor = isMine ? Colors.white.withOpacity(0.7) : AppColors.lightTextTertiary;

    final radius = isMine
        ? BorderRadius.only(topLeft: const Radius.circular(16),
            topRight: showTail ? const Radius.circular(4) : const Radius.circular(16),
            bottomLeft: const Radius.circular(16), bottomRight: const Radius.circular(16))
        : BorderRadius.only(topLeft: showTail ? const Radius.circular(4) : const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: const Radius.circular(16), bottomRight: const Radius.circular(16));

    return Padding(
      padding: EdgeInsets.only(top: showTail ? 8 : 2, bottom: 2,
          left: isMine ? 60 : 0, right: isMine ? 0 : 60),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              decoration: BoxDecoration(color: bgColor, borderRadius: radius,
                  border: isMine ? null : Border.all(color: AppColors.lightBorder, width: 0.5)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.replyToText != null && !deleted)
                    _ReplyPreview(text: message.replyToText!, isMine: isMine),
                  if (message.type == MessageType.image && !deleted)
                    Container(width: 200, height: 140, margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(color: AppColors.lightElevated,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Icon(Icons.image_outlined,
                            size: 32, color: AppColors.lightTextTertiary))),
                  if (deleted)
                    Row(children: [
                      Icon(Icons.block_rounded, size: 12,
                          color: isMine ? Colors.white54 : AppColors.lightTextTertiary),
                      const SizedBox(width: 4),
                      Text('This message was deleted',
                          style: TextStyle(fontFamily: 'Manrope', fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: isMine ? Colors.white54 : AppColors.lightTextTertiary)),
                    ])
                  else if (message.text.isNotEmpty)
                    Text(message.text, style: TextStyle(fontFamily: 'Manrope',
                        fontSize: 14, color: textColor, height: 1.35)),
                  const SizedBox(height: 2),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_fmt(message.timestamp), style: TextStyle(
                        fontFamily: 'Manrope', fontSize: 10, color: timeColor)),
                    if (isMine && !deleted) ...[
                      const SizedBox(width: 4),
                      _StatusIcon(status: message.status),
                    ],
                  ]),
                ]),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime t) {
    final h  = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final mm = t.minute.toString().padLeft(2, '0');
    return '$h:$mm ${t.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class _ReplyPreview extends StatelessWidget {
  final String text;
  final bool isMine;
  const _ReplyPreview({required this.text, required this.isMine});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: isMine ? Colors.white.withOpacity(0.15) : _accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: _accent, width: 3)),
      ),
      child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: 'Manrope', fontSize: 12,
              color: isMine ? Colors.white70 : AppColors.lightTextSecondary)),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final MessageStatus status;
  const _StatusIcon({required this.status});
  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withOpacity(0.8);
    switch (status) {
      case MessageStatus.sending:   return Icon(Icons.access_time_rounded, size: 11, color: color);
      case MessageStatus.sent:      return Icon(Icons.check_rounded, size: 12, color: color);
      case MessageStatus.delivered: return Icon(Icons.done_all_rounded, size: 13, color: color);
      case MessageStatus.read:      return const Icon(Icons.done_all_rounded, size: 13, color: Colors.white);
    }
  }
}

class _ReplyBanner extends StatelessWidget {
  final MessageEntity message;
  final VoidCallback onClose;
  const _ReplyBanner({required this.message, required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      color: AppColors.lightElevated,
      child: Row(children: [
        Container(width: 3, height: 36, color: _accent, margin: const EdgeInsets.only(right: 10)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Replying to', style: TextStyle(fontFamily: 'Manrope',
              fontSize: 11, fontWeight: FontWeight.w600, color: _accent)),
          Text(message.isDeleted ? 'Deleted message' : message.text,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'Manrope', fontSize: 12,
                  color: AppColors.lightTextSecondary)),
        ])),
        IconButton(onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.lightTextTertiary)),
      ]),
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onImageTap;
  const _InputRow({required this.controller, required this.hasText,
      required this.onSend, required this.onImageTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(color: AppColors.lightBg,
          border: Border(top: BorderSide(color: AppColors.lightBorder, width: 0.5))),
      child: SafeArea(top: false, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(onTap: onImageTap,
          child: Container(width: 38, height: 38, margin: const EdgeInsets.only(right: 6, bottom: 3),
            decoration: BoxDecoration(color: AppColors.lightElevated, shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightBorder, width: 0.5)),
            child: const Icon(Icons.image_outlined, size: 18, color: AppColors.lightTextSecondary))),
        Expanded(child: Container(
          constraints: const BoxConstraints(minHeight: 44, maxHeight: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.lightBorder, width: 0.5)),
          child: TextField(controller: controller, maxLines: 5, minLines: 1,
            cursorColor: _accent,
            style: const TextStyle(fontFamily: 'Manrope', fontSize: 14,
                color: AppColors.lightTextPrimary, height: 1.3),
            decoration: const InputDecoration(hintText: 'Message',
                hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 14,
                    color: AppColors.lightTextTertiary),
                border: InputBorder.none, isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12))),
        )),
        const SizedBox(width: 8),
        GestureDetector(onTap: hasText ? onSend : null,
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: hasText ? _accent : AppColors.lightElevated, shape: BoxShape.circle),
            child: Icon(hasText ? Icons.send_rounded : Icons.mic_rounded,
                color: hasText ? Colors.white : AppColors.lightTextSecondary, size: 18))),
      ])),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.lightTextTertiary),
    SizedBox(height: 12),
    Text('No messages yet', style: TextStyle(fontFamily: 'Manrope', fontSize: 14, color: AppColors.lightTextSecondary)),
    SizedBox(height: 4),
    Text('Say hi to get the conversation going',
        style: TextStyle(fontFamily: 'Manrope', fontSize: 12, color: AppColors.lightTextTertiary)),
  ]));
}
