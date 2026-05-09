import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;

  const AppTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _validate() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
      });
    }
  }

  Color get _borderColor {
    if (_errorText != null) return AppColors.danger;
    return AppColors.border;
  }

  Color get _labelColor {
    if (_errorText != null) return AppColors.danger;
    if (_isFocused) return AppColors.accent;
    return AppColors.textTertiary;
  }

  Color get _iconColor {
    if (_errorText != null) return AppColors.danger;
    if (_isFocused) return AppColors.accent;
    return AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            color: _labelColor,
          ),
          child: Text(widget.labelText.toUpperCase()),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor,
              width: _errorText != null ? 1.2 : 1,
            ),
          ),
          child: TextFormField(
            focusNode: _focusNode,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enableSuggestions: widget.enableSuggestions,
            autocorrect: widget.autocorrect,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            cursorColor: AppColors.textPrimary,
            cursorWidth: 1.5,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlignVertical: TextAlignVertical.center,
            onChanged: (_) {
              if (_errorText != null) _validate();
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      child: IconTheme(
                        data: IconThemeData(
                          color: _iconColor,
                          size: 18,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: widget.suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: AppColors.danger,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _errorText!,
                  style: const TextStyle(
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
        ],
      ],
    );
  }
}