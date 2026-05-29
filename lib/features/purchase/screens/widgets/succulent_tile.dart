import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SucculentTile extends StatelessWidget {
  final Succulents succulent;
  final void Function()? onTap;
  const SucculentTile({super.key, required this.succulent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.w),
      child: Card(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: AppColors.lightBorder, width: 0.5.w),
        ),
        child: Container(
          margin: EdgeInsets.only(left: 10.w),
          height: 260.h,
          width: 250.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, right: 10.w),
                child: Container(
                  width: 250.w,
                  height: 170.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    image: DecorationImage(
                      image: NetworkImage(succulent.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.3),
                endIndent: 10.w,
              ),
              Text(
                succulent.name,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                succulent.description,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.lightTextTertiary,
                  fontSize: 12.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PRICE :${succulent.price}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: EdgeInsets.all(15.w),
                      decoration:  BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.r),
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}