// LOGIN SCREEN
// -----------------------------------------------------------------------------
// ConsumerWidget for Riverpod access. State (loading, failure) is owned by
// authController, not by setState. UI just reads the state and renders.
// -----------------------------------------------------------------------------

import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/expense_tracker/expense_auth/domain/auth_failure.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/controllers/auth_controller.dart';
import 'package:app/features/expense_tracker/expense_auth/presentation/expense_signUp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      resizeToAvoidBottomInset: false,
      body: OrbBackground(
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
                    SizedBox(height: 40.h),
                    AppTextField(
                      controller: _usernameCtrl,
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.required(v, 'Username'),
                    ),
                    SizedBox(height: 18.h),
                    AppTextField(
                      controller: _passwordCtrl,
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (v) => AppValidators.password(v),
                    ),
                    if (failure != null) ...[
                      SizedBox(height: 12.h),
                      _ErrorBanner(message: failure.message),
                    ],
                    SizedBox(height: 28.h),
                    AppButton(
                      label: 'Log in',
                      trailingIcon: Icons.arrow_forward_rounded,
                      loading: isLoading,
                      onPressed: isLoading ? null : _submit,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExpenseSignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'New to Expense Tracker? Sign up.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
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
          'Welcome back.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 32.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.1.h,
            letterSpacing: -0.8.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Log in to continue managing your expenses.',
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 0.5.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 14.sp,
            color: AppColors.danger,
          ),
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