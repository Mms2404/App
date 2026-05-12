import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/data/models.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatelessWidget {
  final CartItemModel item;
  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            image: DecorationImage(
              image: NetworkImage(item.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Rs. ${item.price}',
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: AppColors.lightTextSecondary,
          ),
        ),
        trailing: IconButton(
          onPressed: () => context.read<CartModel>().removeItem(item),
          icon: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.lightTextTertiary,
          ),
        ),
      ),
    );
  }
}