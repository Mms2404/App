import 'package:app/features/purchase/data/models.dart';
import 'package:flutter/foundation.dart';

class CartModel extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get total => _items.fold(
    0,
    (sum, i) => sum + (double.tryParse(i.price) ?? 0),
  );

  void addItem(CartItemModel item) {
    _items.add(item);
    notifyListeners();
  }

  void removeItem(CartItemModel item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}