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
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(),
                    SizedBox(height: 32.h),
                    AppTextField(
                      controller: _usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.required(v, 'Username'),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _emailCtrl,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.email(v),
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      controller: _passwordCtrl,
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.password(v),
                    ),
                    SizedBox(height: 16.h),
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
                      SizedBox(height: 12.h),
                      _ErrorBanner(message: failure.message),
                    ],
                    SizedBox(height: 24.h),
                    AppButton(
                      label: 'Create account',
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Already have an account? Log in.',
                          style: TextStyle(
                            fontSize: 12.sp,
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
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(1.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'EXPENSE TRACKER',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.6.w,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Start tracking.',
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.1.h,
            letterSpacing: -0.8.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Create an account to manage your expenses.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.4.h,
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 0.5.w,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14.sp, color: AppColors.danger),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.danger,
                height: 1.3.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}