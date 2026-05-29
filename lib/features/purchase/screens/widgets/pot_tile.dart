import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PotTile extends StatelessWidget {
  final Pots pot;
  final void Function()? onTap;

  const PotTile({super.key, required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Card(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: AppColors.lightBorder, width: 0.5.w),
        ),
        child: Container(
          height: 220.h,
          width: 200.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 5.w, top: 5.h),
                child: Container(
                  height: 150.h,
                  width: 190.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: NetworkImage(pot.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.3),
                indent: 10.w,
                endIndent: 10.w,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  pot.name,
                  style: TextStyle(
                    fontSize: 16 .sp,
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text(
                  pot.material,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.success,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text(
                  'Height : ${pot.height}  ,  Width : ${pot.width}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '  Price : Rs.${pot.price}',
                        style: TextStyle(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Icon(Icons.add, color: Colors.white, size: 16.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}