import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/dialogBox.dart';
import 'package:app/features/authentication/presentation/screens/login_form.dart';
import 'package:app/features/authentication/presentation/screens/signUp_screen.dart';
import 'package:flutter/material.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _BrandMark(),
                const Spacer(flex: 2),
                _HeroHeadline(),
                const SizedBox(height: 20),
                _Tagline(),
                const Spacer(flex: 3),
                _CtaStack(),
                const SizedBox(height: 24),
                _LegalFootnote(),
                const SizedBox(height: 16),
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'MMS',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.4,
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
        const Text(
          'Now',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 0.95,
            letterSpacing: -2,
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
                fontSize: 32,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                color: AppColors.accent,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.6),
                      AppColors.accent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'never.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 0.95,
            letterSpacing: -2,
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
      padding: const EdgeInsets.only(right: 40),
      child: Text(
        'Chat. Shop. Track. Search.\nFive working apps under one roof.',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
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
        const SizedBox(height: 12),
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
            fontSize: 11,
            color: AppColors.textTertiary,
            height: 1.5,
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