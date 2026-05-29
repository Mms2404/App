import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/dialogBox.dart';
import 'package:app/features/authentication/presentation/screens/login_form.dart';
import 'package:app/features/authentication/presentation/screens/signUp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: OrbBackground(
        blurIntensity: 1.4,
        brightness: 0.85,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                _BrandMark(),
                Spacer(flex: 2),
                _HeroHeadline(),
                SizedBox(height: 20.h),
                _Tagline(),
                Spacer(flex: 3),
                _CtaStack(),
                SizedBox(height: 24.h),
                _LegalFootnote(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          'MMS',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4.w,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Now',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 64.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 0.95.h,
            letterSpacing: -2.w,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'or',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32.sp,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: AppColors.accent,
                height: 1.h,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                height: 1.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.6),
                      AppColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'never.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 64.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 0.95.h,
            letterSpacing: -2.w,
          ),
        ),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40.w),
      child: Text(
        'Chat. Shop. Track. Search.\nFive working apps under one roof.',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5.h,
        ),
      ),
    );
  }
}

class _CtaStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppButton(
          label: 'Log in',
          shape: AppButtonShape.top,
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () => AppDialog.show(
            context,
            title: 'Welcome back',
            child: LoginForm(),
          ),
        ),
        SizedBox(height: 12.h),
        AppButton(
          label: 'Create account',
          variant: AppButtonVariant.secondary,
          shape: AppButtonShape.bottom,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SignUpScreen()),
          ),
        ),
      ],
    );
  }
}

class _LegalFootnote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11.sp,
            color: AppColors.textTertiary,
            height: 1.5.h,
          ),
          children: [
            const TextSpan(text: 'By continuing you agree to our '),
            TextSpan(
              text: 'Terms',
              style: TextStyle(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textTertiary,
              ),
            ),
            const TextSpan(text: '  ·  '),
            TextSpan(
              text: 'Privacy',
              style: TextStyle(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}