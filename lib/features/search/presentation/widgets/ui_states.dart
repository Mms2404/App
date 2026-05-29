import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Section header — small icon + uppercase label + optional count badge.
/// Use above grouped content like "Answer", "Videos", "Recent leads".
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.accent),
        SizedBox(width: 8.w),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6.w,
            color: AppColors.textSecondary,
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Tappable pill chip with arrow icon. Use for suggestions, filters,
/// quick actions.
class SuggestionChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<SuggestionChip> {
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.north_east_rounded,
              size: 12.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: 6.w),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen loading. Use for first-load on async screens.
class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({
    super.key,
    this.message = 'Loading…',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32.w,
            height: 32.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small inline loading row. Use within scrollable content while
/// background work continues (pagination, refresh).
class InlineLoading extends StatelessWidget {
  final String message;

  const InlineLoading({
    super.key,
    this.message = 'Loading more…',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14.w,
          height: 14.h,
          child: CircularProgressIndicator(
            strokeWidth: 1.5.w,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          message,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Error fallback with optional retry. Use when an async operation fails.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 32.sp,
              color: AppColors.danger,
            ),
            SizedBox(height: 12.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                  height: 1.4.h,
                ),
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 18.w, vertical: 10.h  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Try again',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}