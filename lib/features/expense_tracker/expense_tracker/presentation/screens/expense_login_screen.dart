// LOGIN SCREEN
// -----------------------------------------------------------------------------
// ConsumerWidget for Riverpod access. State (loading, failure) is owned by
// authController, not by setState. UI just reads the state and renders.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseLoginScreen extends ConsumerStatefulWidget {
  const ExpenseLoginScreen({super.key});

  @override
  ConsumerState<ExpenseLoginScreen> createState() => _ExpenseLoginScreenState();
}

class _ExpenseLoginScreenState extends ConsumerState<ExpenseLoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).login(
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.maybeWhen(
      authenticating: () => true,
      orElse: () => false,
    );
    final failure = state.maybeWhen<AuthFailure?>(
      failed: (AuthFailure f) => f,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: OrbBackground(
        blurIntensity: 1.6,
        brightness: 0.7,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    const SizedBox(height: 40),
                    AppTextField(
                      controller: _usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Username required'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _passwordCtrl,
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Password required' : null,
                    ),
                    if (failure != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: failure.message),
                    ],
                    const SizedBox(height: 28),
                    AppButton(
                      label: 'Log in',
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: wire sign-up flow when built
                        },
                        child: Text(
                          'New to Expense Tracker? Sign up.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'EXPENSE TRACKER',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Welcome back.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Log in to continue managing your expenses.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 14,
            color: AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.danger,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}