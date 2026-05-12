import 'package:app/core/constants/colors.dart';
import 'package:app/features/purchase/providers/cart_model.dart';
import 'package:app/features/purchase/screens/widgets/cartItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 30,
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<CartModel>(
              builder: (_, cart, __) {
                if (cart.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 40,
                          color: AppColors.lightTextTertiary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your cart is empty',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: cart.itemCount,
                  itemBuilder: (_, i) => CartItem(item: cart.items[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}