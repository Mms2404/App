import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LightSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const LightSearchBar({
    required this.controller,
    this.hint = 'Search…',
  });

  @override
  State<LightSearchBar> createState() => LightSearchBarState();
}

class LightSearchBarState extends State<LightSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _focused
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.lightBorder,
          width: _focused ? 1.w : 0.5.w,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.12),
                  blurRadius: 16.r,
                  spreadRadius: -4.r,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14.w, right: 10.w),
            child: Icon(
              Icons.search_rounded,
              size: 18.sp,
              color: _focused
                  ? AppColors.success
                  : AppColors.lightTextTertiary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              cursorColor: AppColors.lightTextPrimary,
              cursorWidth: 1.5.w,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextPrimary,
                height: 1.2.h,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: AppColors.lightElevated,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 14.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
          SizedBox(width: 6.w),
        ],
      ),
    );
  }
}