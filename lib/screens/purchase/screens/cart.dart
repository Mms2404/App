import 'package:app/screens/purchase/models/userCart.dart';
import 'package:app/screens/purchase/screens/widgets/cartItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserCart>(builder:(context, cart, child) => Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("My Cart" ,style: TextStyle(fontSize: 30),),
          SizedBox(height: 20,),
      
          Expanded(
            child: ListView.builder(
              itemCount: cart.getUserCart().length,
              itemBuilder: (context , index){
                final item = cart.getUserCart()[index];
                return CartItem(item: item,);
              }
            )
          )
        ],
      ),
    ),
   );
  }
}