// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navbar extends StatelessWidget {
  final Function(int)? onTabChange;
  const Navbar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightBg,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      child: GNav(
        color: AppColors.lightTextTertiary,
        activeColor: AppColors.success,
        tabBackgroundColor: AppColors.success.withValues(alpha: 0.10),
        tabActiveBorder: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
          width: 0.8.w,
        ),
        tabBorderRadius: 14,
        gap: 10,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        mainAxisAlignment: MainAxisAlignment.center,
        onTabChange: (v) => onTabChange?.call(v),
        tabs: const [
          GButton(icon: Icons.home, text: 'Shop'),
          GButton(icon: Icons.shopping_bag_rounded, text: 'Cart'),
        ],
      ),
    );
  }
}