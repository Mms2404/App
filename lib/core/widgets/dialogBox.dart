import 'dart:ui';
import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDialog {
  /// Shows a centered dialog matching the app's dark cool palette.
  /// 
  /// [title] renders a header row with a close button.
  /// Pass [showClose: false] for confirmation dialogs where the user
  /// must make a deliberate choice.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool showClose = true,
    bool barrierDismissible = true,
    double maxWidth = 440,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.04),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (context, _, __) {
        return _DialogShell(
          title: title,
          showClose: showClose,
          maxWidth: maxWidth,
          child: child,
        );
      },
    );
  }
}

class _DialogShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showClose;
  final double maxWidth;

  const _DialogShell({
    required this.child,
    required this.title,
    required this.showClose,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxH = media.size.height -
        media.viewInsets.bottom -
        media.padding.vertical -
        48.h;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: media.viewInsets.bottom + 20.h,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxH,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.borderStrong,
                        width: 0.5.w,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null || showClose)
                          _DialogHeader(
                            title: title,
                            showClose: showClose,
                          ),
                        Flexible(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              24.w,
                              title == null && !showClose ? 24.h : 4.h,
                              24.w,
                              24.h,
                            ),
                            child: DefaultTextStyle.merge(
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                                height: 1.5.h,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String? title;
  final bool showClose;

  const _DialogHeader({required this.title, required this.showClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 16.w, 12.h),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2.h,
                ),
              ),
            )
          else
            const Spacer(),
          if (showClose)
            _CloseButton(onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: _hovering
                ? AppColors.bgElevated
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 18.sp,
            color: _hovering
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}