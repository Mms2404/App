import 'package:app/common/textField.dart';
import 'package:app/constants/colors.dart';
import 'package:app/screens/purchase/models/userCart.dart';
import 'package:app/screens/purchase/models/models.dart';
import 'package:app/screens/purchase/screens/widgets/pot_tile.dart';
import 'package:app/screens/purchase/screens/widgets/succulent_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState(){
    super.initState();
    // fetches items from Django when Shop page loads
    Provider.of<UserCart>(context, listen: false).fetchAllShopItems();
  }

  // add any item (Succulent or Pot) to cart
  void addItemToCart(dynamic item) {
    Provider.of<UserCart>(context, listen: false).addItem(item);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Successfully added"),
        content: Text("Check your cart"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserCart>(
      builder: (context, cart, child) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              suffixIcon: Icon(Icons.search, color: AppColors.grey),
              controller: searchController,
              labelText: 'Search',
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Highlights ..", style: TextStyle(fontSize: 25)),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 340,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cart.getSucculentsList().length,
                        itemBuilder: (context, index) {
                          Succulents succulent = cart.getSucculentsList()[index];
                          return SucculentTile(
                            succulent: succulent,
                            onTap: () => addItemToCart(succulent),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 20),
                    Text("Choose a pot ..", style: TextStyle(fontSize: 25)),
                    SizedBox(height: 10),

                    
                    SizedBox(
                      height: 320,
                      width: double.infinity,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cart.getPotsList().length,
                        itemBuilder: (context, index) {
                          Pots pot = cart.getPotsList()[index];
                          return PotTile(
                            pot: pot,
                            onTap: () => addItemToCart(pot),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
