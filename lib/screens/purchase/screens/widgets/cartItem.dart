import 'package:app/constants/colors.dart';
import 'package:app/screens/purchase/models/userCart.dart';
import 'package:app/screens/purchase/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartItem extends StatefulWidget {
  final CartItemModel item;
  CartItem({super.key , required this.item});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {

  void removeItem(){
    Provider.of<UserCart>(context , listen: false).removeItem(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:  Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(image: NetworkImage(widget.item.imagePath))
        ),
      ),
      title: Text(widget.item.name),
      subtitle: Text(widget.item.price , style: TextStyle(color: AppColors.grey),),
      trailing: IconButton(
        onPressed: (){
          removeItem();
        }, icon: Icon(Icons.delete))
    );
  }
}