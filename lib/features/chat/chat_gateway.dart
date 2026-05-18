// CHAT GATEWAY
// -----------------------------------------------------------------------------
// Wraps ChatProvider scope. Watches ChatProvider's currentUserPhone:
//   null → PhoneEntryScreen, chrome visible
//   not null → ChatListScreen, chrome hidden
// -----------------------------------------------------------------------------

import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:app/features/chat/screens/chat_list_screen.dart';
import 'package:app/features/chat/screens/phone_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatGateway extends StatelessWidget {
  final ValueChanged<bool> onChromeOverride;
  const ChatGateway({super.key, required this.onChromeOverride});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: _ChatRoot(onChromeOverride: onChromeOverride),
    );
  }
}

class _ChatRoot extends StatefulWidget {
  final ValueChanged<bool> onChromeOverride;
  const _ChatRoot({required this.onChromeOverride});

  @override
  State<_ChatRoot> createState() => _ChatRootState();
}

class _ChatRootState extends State<_ChatRoot> {
  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChromeOverride(true);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<ChatProvider>().currentUserPhone;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChromeOverride(phone == null);
    });

    if (phone == null) {
      return const PhoneEntryScreen();
    }
    return const ChatListScreen();
  }
}