// CHAT GATEWAY — Bloc edition
// -----------------------------------------------------------------------------
// Provides all 3 Blocs at the top level. AuthBloc drives whether we show
// PhoneEntryScreen or ChatListScreen. ChatListBloc + MessagesBloc are provided
// here so they survive navigation between list ↔ detail.
// -----------------------------------------------------------------------------

import 'package:app/features/chat/data/chat_repository.dart';
import 'package:app/features/chat/domain/usecases/chat_usecases.dart';
import 'package:app/features/chat/presentation/auth/bloc/auth_bloc.dart';
import 'package:app/features/chat/presentation/auth/screens/phone_entry_screen.dart';
import 'package:app/features/chat/presentation/chat_list/bloc/chat_list_bloc.dart';
import 'package:app/features/chat/presentation/chat_list/screens/chat_list_screen.dart';
import 'package:app/features/chat/presentation/messages/bloc/messages_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatGateway extends StatelessWidget {
  final ValueChanged<bool> onChromeOverride;
  const ChatGateway({super.key, required this.onChromeOverride});

  @override
  Widget build(BuildContext context) {
    final repo = ChatRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              sendOtp:        SendOtpUseCase(repo),
              verifyOtp:      VerifyOtpUseCase(repo),
              logout:         LogoutUseCase(repo),
              restoreSession: RestoreSessionUseCase(repo),
            )..add(SessionRestoreRequested()),
          ),
          BlocProvider(
            create: (_) => ChatListBloc(
              watchChats:       WatchChatsUseCase(repo),
              searchUsers:      SearchUsersUseCase(repo),
              openOrCreateChat: OpenOrCreateChatUseCase(repo),
            ),
          ),
          BlocProvider(
            create: (_) => MessagesBloc(
              watchMessages: WatchMessagesUseCase(repo),
              sendMessage:   SendMessageUseCase(repo),
              deleteMessage: DeleteMessageUseCase(repo),
              markAsRead:    MarkAsReadUseCase(repo),
            ),
          ),
        ],
        child: _ChatRoot(onChromeOverride: onChromeOverride),
      ),
    );
  }
}

class _ChatRoot extends StatelessWidget {
  final ValueChanged<bool> onChromeOverride;
  const _ChatRoot({required this.onChromeOverride});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, curr) =>
          prev is! AuthAuthenticated && curr is AuthAuthenticated ||
          prev is AuthAuthenticated && curr is! AuthAuthenticated,
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Auth succeeded → subscribe chats stream
          context.read<ChatListBloc>().add(
            ChatListSubscribed(state.phone),
          );
        } else if (state is AuthInitial) {
          // Logged out → unsubscribe
          context.read<ChatListBloc>().add(ChatListUnsubscribed());
        }
      },
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state is AuthAuthenticated
              ? ChatListScreen(
                  key: const ValueKey('list'),
                  onChromeOverride: onChromeOverride,
                )
              : const PhoneEntryScreen(key: ValueKey('entry')),
        );
      },
    );
  }
}
