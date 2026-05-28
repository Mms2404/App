// SIGN UP SCREEN
// -----------------------------------------------------------------------------
// Mirrors LoginScreen pattern: ConsumerStatefulWidget, watches auth state,
// reads controller for actions. Auto-logs-in on success (auth state becomes
// authenticated → gateway swaps to expense list).
// -----------------------------------------------------------------------------

import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpenseSignUpScreen extends ConsumerStatefulWidget {
  const ExpenseSignUpScreen({super.key});

  @override
  ConsumerState<ExpenseSignUpScreen> createState() => _ExpenseSignUpScreenState();
}

class _ExpenseSignUpScreenState extends ConsumerState<ExpenseSignUpScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authControllerProvider.notifier).signUp(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirm: _confirmCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {

    // Pop back to gateway when signup succeeds
  ref.listen(authControllerProvider, (previous, next) {
    final wasAuthed = previous?.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        ) ??
        false;
    final isAuthed = next.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    if (!wasAuthed && isAuthed && mounted) {
      Navigator.pop(context);
    }
  });
  
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
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.required(v, 'Username'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailCtrl,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.email(v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordCtrl,
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.password(v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmCtrl,
                      labelText: 'Confirm password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => AppValidators.confirmPassword(v, _passwordCtrl.text),
                    ),
                    if (failure != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: failure.message),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Create account',
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Already have an account? Log in.',
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
          'Start tracking.',
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
          'Create an account to manage your expenses.',
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
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
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