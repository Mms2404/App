// EXPENSE TRACKER GATEWAY
// -----------------------------------------------------------------------------
// The entry point for the expense tracker feature. Watches auth state and
// shows either Login or the Expense List.
//
// This is the cleanest pattern for auth-gated features in Riverpod:
//   1. The gateway watches authControllerProvider
//   2. When state is Authenticated → show authed UI
//   3. When state is anything else → show LoginScreen
//   4. Logout transitions the state → gateway automatically swaps back
//
// No callbacks. No manual navigation between login and home. Reactive flow.
//
// This file lives OUTSIDE the auth/tracker subfeatures because it composes
// them. It's the "feature root" for the expense tracker as a whole.
// -----------------------------------------------------------------------------

import 'package:app/features/expense_tracker/expense_auth/expense_login_screen.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/expense_tracker/expense_tracker/presentation/screens/expense_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseTrackerGateway extends ConsumerStatefulWidget {
  final ValueChanged<bool> onChromeOverride;
  const ExpenseTrackerGateway({super.key, required this.onChromeOverride});

  @override
  ConsumerState<ExpenseTrackerGateway> createState() =>
      _ExpenseTrackerGatewayState();
}

class _ExpenseTrackerGatewayState extends ConsumerState<ExpenseTrackerGateway> {
  @override
  void dispose() {
    // Restore chrome visibility when leaving the feature.
    // Wrap in post-frame to avoid setState-during-build in parent.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChromeOverride(true);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isAuthed = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    // Sync chrome visibility with auth state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChromeOverride(!isAuthed);
    });

    return authState.maybeWhen(
      authenticated: (token) => const ExpenseListScreen(),
      orElse: () => const ExpenseLoginScreen(),
    );
  }
}