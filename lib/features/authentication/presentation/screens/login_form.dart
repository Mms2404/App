import 'package:app/core/constants/colors.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/core/utils/rive.dart';
import 'package:app/core/utils/validators.dart';
import 'package:app/core/widgets/buttons.dart';
import 'package:app/core/widgets/textField.dart';
import 'package:app/features/authentication/presentation/screens/signUp_screen.dart';
import 'package:app/app_home.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isShowLoading = false;

  SMITrigger? _check;
  SMITrigger? _error;
  SMITrigger? _reset;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }


  Future<void> _handleSubmit() async {
    setState(() => _isShowLoading = true);

    // Give Rive time to mount and run onInit
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // log.d('Email value: "${_emailCtrl.text}"');
    // log.d('Password value: "${_passwordCtrl.text}"');
    // log.d('Form state: ${_formKey.currentState}');
    final isValid = _formKey.currentState?.validate() ?? false;
    // log.d('isValid: $isValid');

    if (isValid) {
      _check?.fire();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isShowLoading = false);

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Home()),
      );
    } else {
      log.d("Error SMI is: ${_error?.toString()}");
      _error?.fire();
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _isShowLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _emailCtrl,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => AppValidators.email(v),
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _passwordCtrl,
                labelText: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (v) => AppValidators.password(v,min: 6),
                onFieldSubmitted: (_) => _handleSubmit(),
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isShowLoading ? null : () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Log in',
                shape: AppButtonShape.top,
                trailingIcon: Icons.arrow_forward_rounded,
                loading: _isShowLoading,
                onPressed: _isShowLoading ? null : _handleSubmit,
              ),
              const SizedBox(height: 20),
              _OrDivider(),
              const SizedBox(height: 20),
              AppButton(
                label: "Don't have an account?",
                variant: AppButtonVariant.secondary,
                shape: AppButtonShape.bottom,
                onPressed: _isShowLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SignUpScreen()),
                        );
                      },
              ),
            ],
          ),
        ),

        // Rive check/error animation overlay
        if (_isShowLoading)
          _RiveOverlay(
            size: 100,
            child: RiveAnimation.asset(
              'assets/rive/check_error.riv',
              onInit: (artboard) {
                final controller = RiveUtils.getRiveController(artboard);
                _check = controller.findSMI('Check') as SMITrigger;
                _error = controller.findSMI('Error') as SMITrigger;
                _reset = controller.findSMI('Reset') as SMITrigger;
              },
            ),
          ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 0.5, color: AppColors.border),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.4,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ],
    );
  }
}

class _RiveOverlay extends StatelessWidget {
  final Widget child;
  final double size;

  const _RiveOverlay({required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: AppColors.bgBase.withOpacity(0.4),
          alignment: Alignment.center,
          child: Container(
            width: size + 24,
            height: size + 24,
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderStrong,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: size,
              height: size,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}