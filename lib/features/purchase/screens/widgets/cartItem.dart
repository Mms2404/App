import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final CartItemModel item;
  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical:  4.h),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.lightBorder, width: 0.5.w),
      ),
      child: ListTile(
        leading: Container(
          height: 50.h,
          width: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            image: DecorationImage(
              image: NetworkImage(item.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Rs. ${item.price}',
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
          ),
        ),
        trailing: IconButton(
          onPressed: () => context.read<CartModel>().removeLine(item),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ),
    );
  }
}