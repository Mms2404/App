import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }
enum AppButtonShape { common, top, bottom }
enum AppButtonSize { regular, compact }

/// Static styles, kept for cases where you only need a `ButtonStyle`.
/// For real button instances, prefer `AppButton` below.
class AppButtonStyles {
  static const _commonRadius = BorderRadius.all(Radius.circular(20));

  static const _topRadius = BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(25),
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(25),
  );

  static const _bottomRadius = BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
    bottomLeft: Radius.circular(25),
    bottomRight: Radius.circular(10),
  );

  static ButtonStyle _build(BorderRadius radius) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.bgBase,
      disabledBackgroundColor: AppColors.bgElevated,
      disabledForegroundColor: AppColors.textDisabled,
      minimumSize: const Size(double.infinity, 52),
      elevation: 0,
      shadowColor: Colors.transparent,
      textStyle: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      shape: RoundedRectangleBorder(borderRadius: radius),
    );
  }

  static ButtonStyle commonButton = _build(_commonRadius);
  static ButtonStyle topButton = _build(_topRadius);
  static ButtonStyle bottomButton = _build(_bottomRadius);
}

/// Drop-in replacement for `ElevatedButton`. Handles variants, sizes,
/// the asymmetric corner shapes, loading state, icons, and pressed feedback.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonShape shape;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool loading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.shape = AppButtonShape.common,
    this.size = AppButtonSize.regular,
    this.leadingIcon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null || widget.loading;

  BorderRadius get _radius {
    switch (widget.shape) {
      case AppButtonShape.top:
        return AppButtonStyles._topRadius;
      case AppButtonShape.bottom:
        return AppButtonStyles._bottomRadius;
      case AppButtonShape.common:
        return AppButtonStyles._commonRadius;
    }
  }

  double get _height =>
      widget.size == AppButtonSize.compact ? 40 : 52;

  double get _fontSize =>
      widget.size == AppButtonSize.compact ? 13 : 15;

  _ButtonColors _colors() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _ButtonColors(
          bg: AppColors.accent,
          fg: AppColors.bgBase,
          border: null,
          pressedBg: AppColors.accentDeep,
        );
      case AppButtonVariant.secondary:
        return _ButtonColors(
          bg: AppColors.bgSurface,
          fg: AppColors.textPrimary,
          border: AppColors.borderStrong,
          pressedBg: AppColors.bgElevated,
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          bg: AppColors.danger.withOpacity(0.12),
          fg: AppColors.danger,
          border: AppColors.danger.withOpacity(0.4),
          pressedBg: AppColors.danger.withOpacity(0.20),
        );
      case AppButtonVariant.ghost:
        return _ButtonColors(
          bg: Colors.transparent,
          fg: AppColors.textSecondary,
          border: null,
          pressedBg: AppColors.bgSurface,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    final disabled = _disabled;

    final bg = disabled
        ? AppColors.bgElevated
        : (_pressed ? colors.pressedBg : colors.bg);
    final fg = disabled ? AppColors.textDisabled : colors.fg;
    final borderColor = disabled
        ? AppColors.border
        : (colors.border ?? Colors.transparent);

    final button = AnimatedScale(
      scale: _pressed && !disabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: _height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: _radius,
          border: Border.all(
            color: borderColor,
            width: colors.border != null ? 0.8 : 0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: disabled ? null : widget.onPressed,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            borderRadius: _radius,
            splashColor: fg.withOpacity(0.08),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: widget.loading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(fg),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.leadingIcon != null) ...[
                            Icon(widget.leadingIcon, size: 16, color: fg),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: _fontSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: fg,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (widget.trailingIcon != null) ...[
                            const SizedBox(width: 8),
                            Icon(widget.trailingIcon, size: 16, color: fg),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    return widget.fullWidth ? button : IntrinsicWidth(child: button);
  }
}

class _ButtonColors {
  final Color bg;
  final Color fg;
  final Color? border;
  final Color pressedBg;

  _ButtonColors({
    required this.bg,
    required this.fg,
    required this.border,
    required this.pressedBg,
  });
}