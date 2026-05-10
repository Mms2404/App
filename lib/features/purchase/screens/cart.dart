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
          const Text('My Cart', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<CartModel>(
              builder: (_, cart, __) {
                if (cart.isEmpty) {
                  return const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 14),
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