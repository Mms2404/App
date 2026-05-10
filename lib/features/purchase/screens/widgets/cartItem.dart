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
    return ListTile(
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(image: NetworkImage(item.imagePath)),
        ),
      ),
      title: Text(item.name),
      subtitle: Text(item.price, style: const TextStyle(color: AppColors.grey)),
      trailing: IconButton(
        onPressed: () => context.read<CartModel>().removeItem(item),
        icon: const Icon(Icons.delete),
      ),
    );
  }
}