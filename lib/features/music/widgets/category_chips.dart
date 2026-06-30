import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal scroll of category filter chips. null = "All".
class CategoryChips extends StatelessWidget {
  final SongCategory? selected;
  final ValueChanged<SongCategory?> onSelected;

  const CategoryChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          _Chip(label: 'All', selected: selected == null, onTap: () => onSelected(null)),
          ...SongCategory.values
              .where((c) => c != SongCategory.recording)
              .map((c) => _Chip(
                    label: c.label,
                    selected: selected == c,
                    onTap: () => onSelected(c),
                  )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: selected ? AppColors.accent : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.bgBase : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
