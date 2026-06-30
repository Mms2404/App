import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/enum.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/authentication/presentation/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/core/utils/validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          contactInfo: _emailCtrl.text.trim(),
          contactType: ContactType.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: OrbBackground(
        blurIntensity: 1.6,
        brightness: 0.6,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(onBack: () => Navigator.pop(context)),
                SizedBox(height: 32.h),
                _TitleBlock(),
                SizedBox(height: 32.h),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
  controller: _nameCtrl,
  labelText: 'Full name',
  prefixIcon: const Icon(Icons.person_outline_rounded),
  textInputAction: TextInputAction.next,
  validator: (v) => AppValidators.minLength(v, 2, 'Name'),
),
SizedBox(height: 18.h),
AppTextField(
  controller: _emailCtrl,
  labelText: 'Email',
  prefixIcon: const Icon(Icons.mail_outline_rounded),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  validator: AppValidators.email,
),
SizedBox(height: 18.h),
AppTextField(
  controller: _phoneCtrl,
  labelText: 'Phone number',
  prefixIcon: const Icon(Icons.phone_outlined),
  keyboardType: TextInputType.phone,
  textInputAction: TextInputAction.next,
  validator: AppValidators.phone,
),
SizedBox(height: 18.h),
AppTextField(
  controller: _passwordCtrl,
  labelText: 'Password',
  prefixIcon: const Icon(Icons.lock_outline_rounded),
  obscureText: _obscurePassword,
  textInputAction: TextInputAction.next,
  validator: (v) => AppValidators.password(v, min: 6),
  suffixIcon: _VisibilityToggle(
    obscured: _obscurePassword,
    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
  ),
),
SizedBox(height: 18.h),
AppTextField(
  controller: _confirmPasswordCtrl,
  labelText: 'Confirm password',
  prefixIcon: const Icon(Icons.lock_outline_rounded),
  obscureText: _obscureConfirmPassword,
  textInputAction: TextInputAction.done,
  validator: (v) => AppValidators.confirmPassword(v, _passwordCtrl.text),
  onFieldSubmitted: (_) => _submit(),
  suffixIcon: _VisibilityToggle(
    obscured: _obscureConfirmPassword,
    onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
  ),
),
                      SizedBox(height: 32.h),
                      AppButton(
                        label: 'Create account',
                        trailingIcon: Icons.arrow_forward_rounded,
                        loading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                      SizedBox(height: 16.h),
                      _LegalFootnote(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
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
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'GET STARTED',
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
          'Create your account',
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
          'A few details and you\'re in.',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4.h,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color:
              _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Icon(
          widget.icon,
          size: 18.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;

  const _VisibilityToggle({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(right: 14.w, left: 8.w),
        child: Icon(
          obscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18.sp,
          color: AppColors.textTertiary,
        ),
      ),
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
            fontSize: 11.sp,
            color: AppColors.textTertiary,
            height: 1.5.h,
          ),
          children: [
            const TextSpan(text: 'By creating an account you agree to our '),
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