import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:app/features/chat/screens/chat_list_screen.dart';
import 'package:app/features/chat/screens/phone_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatGateway extends StatelessWidget {
  const ChatGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const _ChatRoot(),
    );
  }
}

class _ChatRoot extends StatelessWidget {
  const _ChatRoot();

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<ChatProvider>().currentUserPhone;
    if (phone == null) {
      return const PhoneEntryScreen();
    }
    return const ChatListScreen();
  }
}