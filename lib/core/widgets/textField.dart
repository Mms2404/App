import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1.w,
            color: _labelColor,
          ),
          child: Text(widget.labelText.toUpperCase()),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _borderColor,
              width: _errorText != null ? 1.2.w : 1.w,
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
            validator: (value) {                                  // ← add this block
    if (widget.validator == null) return null;
    final result = widget.validator!(value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _errorText = result);
    });
    return result;
  },
            cursorColor: AppColors.textPrimary,
            cursorWidth: 1.5.w,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.2.h,
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
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              focusedErrorBorder: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 16.h,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: EdgeInsets.only(left: 14.w, right: 10.w),
                      child: IconTheme(
                        data: IconThemeData(
                          color: _iconColor,
                          size: 18.sp,
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
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13.sp,
                color: AppColors.danger,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  _errorText!,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.danger,
                    height: 1.3.h,
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

class LightTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final String? prefixText;          // e.g. "+91" for phone
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final void Function(String)? onFieldSubmitted;
  final int maxLines;                // 1 = single line, >1 = multi-line
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const LightTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<LightTextField> createState() => _LightTextFieldState();
}

class _LightTextFieldState extends State<LightTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _errorText;

  bool get _multiline => widget.maxLines > 1;

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

  void _revalidate() {
    if (widget.validator != null) {
      setState(() => _errorText = widget.validator!(widget.controller.text));
    }
  }

  Color get _borderColor {
    if (_errorText != null) return AppColors.danger;
    if (_isFocused) return AppColors.success.withOpacity(0.5);
    return AppColors.lightBorder;
  }

  Color get _labelColor {
    if (_errorText != null) return AppColors.danger;
    if (_isFocused) return AppColors.success;
    return AppColors.lightTextTertiary;
  }

  Color get _iconColor {
    if (_errorText != null) return AppColors.danger;
    if (_isFocused) return AppColors.success;
    return AppColors.lightTextTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Uppercase label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1.w,
            color: _labelColor,
          ),
          child: Text(widget.labelText.toUpperCase()),
        ),
        SizedBox(height: 6.h),

        // Field container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _borderColor,
              width: (_errorText != null || _isFocused) ? 1.w : 0.5.w,
            ),
            boxShadow: _isFocused && _errorText == null
                ? [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha:0.12),
                      blurRadius: 16.r,
                      spreadRadius: -4.r,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: _multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              // Prefix icon
              if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: 14.w,
                    right: 10.w,
                    top: _multiline ? 16.h : 0.h,
                  ),
                  child: IconTheme(
                    data: IconThemeData(color: _iconColor, size: 18.sp),
                    child: widget.prefixIcon!,
                  ),
                ),

              // Prefix text (e.g. +91) with a divider
              if (widget.prefixText != null) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    widget.prefixText!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Container(
                  width: 0.5.w,
                  height: 24.h,
                  color: AppColors.lightBorder,
                ),
              ],

              // The actual field
              Expanded(
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  textInputAction: widget.textInputAction,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  maxLines: widget.maxLines,
                  minLines: _multiline ? widget.maxLines - 1 : 1,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  cursorColor: AppColors.lightTextPrimary,
                  cursorWidth: 1.5.w,
                  // Wires the validator into Form.validate() AND syncs our
                  // own _errorText so the error shows below the field.
                  validator: (value) {
                    if (widget.validator == null) return null;
                    final result = widget.validator!(value);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _errorText = result);
                    });
                    return result;
                  },
                  onChanged: (_) {
                    if (_errorText != null) _revalidate();
                  },
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.lightTextPrimary,
                    height: 1.3.h,
                  ),
                  textAlignVertical:
                      _multiline ? TextAlignVertical.top : TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.lightTextTertiary,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    // Hide TextFormField's built-in error — we render our own below
                    errorStyle: TextStyle(height: 0, fontSize: 0),
                    counterText: '',
                    isCollapsed: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: (widget.prefixText != null) ? 12.w : 14.w,
                      vertical: 16.h,
                    ),
                    suffixIcon: widget.suffixIcon,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error text BELOW the field
        if (_errorText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13.sp,
                color: AppColors.danger,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  _errorText!,
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
        ],
      ],
    );
  }
}