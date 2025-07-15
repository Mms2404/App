import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

class UserCart extends ChangeNotifier {

  // These will be populated from the API
  List<Succulents> succulentShop = [];
  List<Pots> potShop = [];

  List<CartItemModel> userCart = [];

  // API base URL
  final String baseUrl = "http://10.36.193.18:8000/api"; 

  List<Succulents> getSucculentsList() => succulentShop;
  List<Pots> getPotsList() => potShop;
  List<CartItemModel> getUserCart() => userCart;

  // Add and remove from cart
  void addItem(CartItemModel item) {
    userCart.add(item);
    notifyListeners();
  }

  void removeItem(CartItemModel item) {
    userCart.remove(item);
    notifyListeners();
  }

  //  Load data from Django
  Future<void> fetchSucculents() async {
    final response = await http.get(Uri.parse('$baseUrl/succulents/'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      succulentShop = data.map((json) => Succulents(
        name: json['name'],
        imagePath: json['image_path'],
        price: json['price'].toString(),
        description: json['description'],
      )).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load succulents');
    }
  }

  Future<void> fetchPots() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/pots/'));
    print("POTS STATUS: ${response.statusCode}");
    print("POTS BODY: ${response.body}");
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      potShop = data.map((json) => Pots(
        name: json['name'],
        imagePath: json['image_path'],
        material: json['material'],
        height: json['height'],
        width: json['width'],
        price: json['price'].toString(),
        description: json['description'],
      )).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load pots');
    }
  } catch (e) {
    print("FETCH POTS ERROR: $e");
  }
}


  //  call both shops
  Future<void> fetchAllShopItems() async {
    await Future.wait([fetchSucculents(), fetchPots()]);
  }
}
