import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/enum.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/app_home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app/core/utils/validators.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationScreen extends StatefulWidget {
  final String contactInfo;
  final ContactType contactType;

  const VerificationScreen({
    super.key,
    required this.contactInfo,
    required this.contactType,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();

  bool _isCodeSent = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification successful!')),
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
  }

  void _resendCode() {
    setState(() => _isCodeSent = false);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isCodeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent')),
      );
    });
  }

  String get _subtitle => widget.contactType == ContactType.email
      ? 'Enter the code we sent to your email.'
      : 'Enter the code we sent to your phone.';

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
                _TitleBlock(subtitle: _subtitle, contact: widget.contactInfo),
                SizedBox(height: 32.h),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _codeCtrl,
                        labelText: 'Verification code',
                        prefixIcon: const Icon(Icons.confirmation_num_outlined),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: (v) => AppValidators.minLength(v, 4, 'Code'),
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      SizedBox(height: 32.h),
                      AppButton(
                        label: 'Verify',
                        trailingIcon: Icons.arrow_forward_rounded,
                        loading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                      SizedBox(height: 16.h),
                      _ResendFootnote(
                        isCodeSent: _isCodeSent,
                        onResend: _resendCode,
                      ),
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
        _IconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String subtitle;
  final String contact;
  const _TitleBlock({required this.subtitle, required this.contact});

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
              'VERIFY',
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
          'Check your inbox',
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
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.4.h,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          contact,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
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
          color: _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Icon(widget.icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class _ResendFootnote extends StatelessWidget {
  final bool isCodeSent;
  final VoidCallback onResend;
  const _ResendFootnote({required this.isCodeSent, required this.onResend});

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
            const TextSpan(text: 'Didn\'t get a code?  '),
            TextSpan(
              text: isCodeSent ? 'Resend' : 'Sending...',
              style: TextStyle(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.textTertiary,
              ),
              recognizer: isCodeSent
                  ? (TapGestureRecognizer()..onTap = onResend)
                  : null,
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}