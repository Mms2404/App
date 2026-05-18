// PHONE ENTRY SCREEN
// -----------------------------------------------------------------------------
// Two stages on one screen:
//   1. Phone number field → "Send OTP"
//   2. OTP boxes appear below the phone field → "Verify"
//
// Any 6-digit OTP succeeds (no backend yet). After verify, transitions to
// chat list via ChatProvider.login(phone).
// -----------------------------------------------------------------------------

import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/provider/chat_provider.dart';
import 'package:app/features/chat/screens/chat_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  static const Color _chatAccent = Color(0xFF1FA088);

  final _phoneCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  bool _otpStage = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _otpStage = true;
    });

    // Auto-focus first OTP digit
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _otpFocus[0].requestFocus();
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Any 6-digit code succeeds
    context.read<ChatProvider>().login(_phoneCtrl.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatListScreen()),
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocus[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
    setState(() => _errorMessage = null);
  }

  void _changeNumber() {
    setState(() {
      _otpStage = false;
      _errorMessage = null;
      for (final c in _otpCtrls) c.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _BackArrow(),
              const Spacer(flex: 1),
              _IconBadge(),
              const SizedBox(height: 32),
              const _Headline(),
              const SizedBox(height: 12),
              _Subhead(otpStage: _otpStage, phone: _phoneCtrl.text.trim()),
              const SizedBox(height: 36),
              _PhoneField(
                controller: _phoneCtrl,
                enabled: !_otpStage,
                accent: _chatAccent,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: _otpStage
                    ? Column(
                        children: [
                          const SizedBox(height: 24),
                          _OtpRow(
                            controllers: _otpCtrls,
                            focusNodes: _otpFocus,
                            onChanged: _onOtpChanged,
                            accent: _chatAccent,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _changeNumber,
                            child: Text(
                              'Wrong number? Change',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 12,
                                color: _chatAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: _errorMessage!),
              ],
              const Spacer(flex: 2),
              _ChatPrimaryButton(
                label: _otpStage ? 'Verify' : 'Send OTP',
                isLoading: _isLoading,
                accent: _chatAccent,
                onPressed: _isLoading
                    ? null
                    : (_otpStage ? _verifyOtp : _sendOtp),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightBorder, width: 0.5),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 18,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF1FA088);
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withOpacity(0.25), width: 0.8),
        ),
        child: const Icon(Icons.chat_rounded, size: 36, color: accent),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your number,\nyour chats.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.1,
        letterSpacing: -0.8,
      ),
    );
  }
}

class _Subhead extends StatelessWidget {
  final bool otpStage;
  final String phone;

  const _Subhead({required this.otpStage, required this.phone});

  @override
  Widget build(BuildContext context) {
    final text = otpStage
        ? 'We sent a 6-digit code to +91 $phone'
        : 'We\'ll send you a verification code.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 13,
          color: AppColors.lightTextSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _PhoneField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final Color accent;

  const _PhoneField({
    required this.controller,
    required this.enabled,
    required this.accent,
  });

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = !widget.enabled
        ? AppColors.lightBorder
        : _focused
            ? widget.accent.withOpacity(0.5)
            : AppColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: widget.enabled
            ? AppColors.lightSurface
            : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: _focused ? 1 : 0.5,
        ),
        boxShadow: _focused && widget.enabled
            ? [
                BoxShadow(
                  color: widget.accent.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '+91',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.enabled
                    ? AppColors.lightTextPrimary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ),
          Container(
            width: 0.5,
            height: 24,
            color: AppColors.lightBorder,
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: TextInputType.phone,
              cursorColor: AppColors.lightTextPrimary,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: AppColors.lightTextPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Phone number',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: AppColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                counterText: '',
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;
  final Color accent;

  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
            controller: controllers[i],
            focusNode: focusNodes[i],
            onChanged: (v) => onChanged(i, v),
            accent: accent,
          )),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final Color accent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.accent,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    final borderColor = _focused
        ? widget.accent
        : filled
            ? widget.accent.withOpacity(0.4)
            : AppColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: _focused ? 1.2 : 0.5),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        cursorColor: widget.accent,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _ChatPrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color accent;
  final VoidCallback? onPressed;

  const _ChatPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.accent,
    required this.onPressed,
  });

  @override
  State<_ChatPrimaryButton> createState() => _ChatPrimaryButtonState();
}

class _ChatPrimaryButtonState extends State<_ChatPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52,
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.lightElevated
              : _pressed
                  ? widget.accent.withOpacity(0.85)
                  : widget.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: disabled
                        ? AppColors.lightTextTertiary
                        : Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
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
          const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}