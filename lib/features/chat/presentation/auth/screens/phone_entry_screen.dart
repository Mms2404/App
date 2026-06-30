// PHONE ENTRY SCREEN — Bloc edition
// Listens to AuthBloc state. No business logic here — pure UI.

import 'package:app/core/constants/colors.dart';
import 'package:app/features/chat/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _accent = Color(0xFF1FA088);

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});
  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneCtrl.text.trim();
    final name  = _nameCtrl.text.trim();
    if (phone.length < 10) { _showError('Enter a valid 10-digit number.'); return; }
    if (name.isEmpty)       { _showError('Enter your name.');              return; }
    context.read<AuthBloc>().add(SendOtpRequested(phone: phone, name: name));
    Future.delayed(const Duration(milliseconds: 400),
        () => _otpFocus[0].requestFocus());
  }

  void _verifyOtp() {
    final otp  = _otpCtrls.map((c) => c.text).join();
    final name = _nameCtrl.text.trim();
    if (otp.length < 6) { _showError('Enter all 6 digits.'); return; }
    context.read<AuthBloc>().add(VerifyOtpRequested(otp: otp, name: name));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) _otpFocus[index + 1].requestFocus();
    if (value.isEmpty   && index > 0)   _otpFocus[index - 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ));
          if (state.wasOtpStage) {
            for (final c in _otpCtrls) c.clear();
            _otpFocus[0].requestFocus();
          }
        }
      },
      builder: (context, state) {
        final isOtpStage = state is OtpSent;
        final isLoading  = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.lightBg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _accent.withValues(alpha: 0.25), width: 0.8),
                      ),
                      child: const Icon(Icons.chat_rounded, size: 36, color: _accent),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    isOtpStage ? 'Enter the code' : 'Your number,\nyour chats.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTextPrimary,
                      height: 1.1, letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isOtpStage
                        ? 'We sent a 6-digit code to +1 ${_phoneCtrl.text.trim()}'
                        : 'Enter your name and phone number to get started.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Manrope', fontSize: 13,
                      color: AppColors.lightTextSecondary, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _LightField(controller: _nameCtrl, hint: 'Your name',
                      icon: Icons.person_outline_rounded, enabled: !isOtpStage),
                  const SizedBox(height: 12),
                  _PhoneField(controller: _phoneCtrl, enabled: !isOtpStage),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    child: isOtpStage
                        ? Column(children: [
                            const SizedBox(height: 24),
                            _OtpRow(controllers: _otpCtrls,
                                focusNodes: _otpFocus, onChanged: _onOtpChanged),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => context.read<AuthBloc>().add(OtpResetRequested()),
                              child: const Text('Wrong number? Change',
                                  style: TextStyle(fontFamily: 'Manrope', fontSize: 12,
                                      color: _accent, fontWeight: FontWeight.w500)),
                            ),
                          ])
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 40),
                  _PrimaryButton(
                    label: isOtpStage ? 'Verify' : 'Send OTP',
                    loading: isLoading,
                    onTap: isLoading ? null : (isOtpStage ? _verifyOtp : _sendOtp),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Shared input widgets (same as before) ────────────────────────────────────

class _LightField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;
  const _LightField({required this.controller, required this.hint,
      required this.icon, this.enabled = true});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.lightSurface : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 0.5),
      ),
      child: TextField(
        controller: controller, enabled: enabled,
        style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.lightTextPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.lightTextTertiary),
          prefixIcon: Icon(icon, size: 18, color: AppColors.lightTextTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const _PhoneField({required this.controller, required this.enabled});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: enabled ? AppColors.lightSurface : AppColors.lightElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 0.5),
      ),
      child: Row(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('+1', style: TextStyle(fontFamily: 'Manrope', fontSize: 15,     // for testing the number format is +1 123 456 7890, but for India it should be +91 12345 67890
              fontWeight: FontWeight.w600,
              color: enabled ? AppColors.lightTextPrimary : AppColors.lightTextTertiary))),
        Container(width: 0.5, height: 24, color: AppColors.lightBorder),
        Expanded(child: TextField(
          controller: controller, enabled: enabled,
          keyboardType: TextInputType.phone, maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.lightTextPrimary),
          decoration: const InputDecoration(hintText: 'Phone number',
            hintStyle: TextStyle(fontFamily: 'Manrope', fontSize: 15, color: AppColors.lightTextTertiary),
            border: InputBorder.none, counterText: '', isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
        )),
      ]),
    );
  }
}

class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onChanged;
  const _OtpRow({required this.controllers, required this.focusNodes, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) => _OtpBox(
          controller: controllers[i], focusNode: focusNodes[i],
          onChanged: (v) => onChanged(i, v))),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});
  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() => setState(() => _focused = widget.focusNode.hasFocus));
  }
  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 44, height: 52,
      decoration: BoxDecoration(
        color: AppColors.lightSurface, borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _focused ? _accent : filled ? _accent.withValues(alpha: 0.4) : AppColors.lightBorder,
          width: _focused ? 1.2 : 0.5),
      ),
      child: TextField(
        controller: widget.controller, focusNode: widget.focusNode,
        textAlign: TextAlign.center, keyboardType: TextInputType.number,
        maxLength: 1, cursorColor: _accent,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontFamily: 'Manrope', fontSize: 18,
            fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary),
        decoration: const InputDecoration(border: InputBorder.none,
            counterText: '', isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 14)),
        onChanged: widget.onChanged,
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, required this.loading, required this.onTap});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120), height: 52,
        decoration: BoxDecoration(
          color: disabled ? AppColors.lightElevated
              : _pressed ? _accent.withValues(alpha: 0.85) : _accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: widget.loading
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Text(widget.label, style: TextStyle(fontFamily: 'Manrope',
                fontSize: 15, fontWeight: FontWeight.w600,
                color: disabled ? AppColors.lightTextTertiary : Colors.white))),
      ),
    );
  }
}
