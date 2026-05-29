import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Purchase extends StatelessWidget {
  const Purchase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),
              _IconBadge(),
              SizedBox(height: 32.h),
              _BrandTag(),
              SizedBox(height: 16.h),
              const _Headline(),
              SizedBox(height: 14.h),
              const _Subhead(),
              const Spacer(flex: 3),
              _CtaBlock(),
              SizedBox(height: 24.h),
              const _MetaRow(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88.w,
        height: 88.h,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.35),
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.25),
              blurRadius: 24.r,
              spreadRadius: -4.r,
            ),
          ],
        ),
        child: Icon(
          Icons.spa_rounded,
          size: 40.sp,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _BrandTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'PLANT SHOP',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6.w,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Find your\nperfect plant.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        height: 1.1.h,
        letterSpacing: -1.w,
      ),
    );
  }
}

class _Subhead extends StatelessWidget {
  const _Subhead();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        'Easy-care succulents and houseplants, delivered to your door.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextSecondary,
          height: 1.5.h,
        ),
      ),
    );
  }
}

class _CtaBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _LightPrimaryButton(
      label: 'Browse plants',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Home()),
        );
      },
    );
  }
}

class _LightPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _LightPrimaryButton({required this.label, required this.onPressed});

  @override
  State<_LightPrimaryButton> createState() => _LightPrimaryButtonState();
}

class _LightPrimaryButtonState extends State<_LightPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 52.h,
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF2E7D4F) : AppColors.success,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.2.w,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward_rounded, size: 16.sp, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _MetaChip(icon: Icons.local_shipping_outlined, label: 'Door step delivery'),
        SizedBox(width: 12.w),
        _Dot(),
        SizedBox(width: 12.w),
        _MetaChip(icon: Icons.workspace_premium_outlined, label: '30-day guarantee'),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: AppColors.lightTextTertiary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3.w,
      height: 3.h,
      decoration: BoxDecoration(
        color: AppColors.lightTextTertiary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}