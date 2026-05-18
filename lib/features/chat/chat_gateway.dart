import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:app/features/chat/screens/phone_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatGateway extends StatelessWidget{
  const ChatGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const PhoneEntryScreen(),
    );
  }
}