import 'package:app/features/purchase/data/models.dart';
import 'package:flutter/foundation.dart';

// A single line in the cart: one product + how many of it.
// We use this instead of storing duplicate CartItemModel entries because
// "Cactus ×3" is cleaner to display and calculate than three identical objects.
class CartLine {
  final CartItemModel item;
  int qty;

  CartLine({required this.item, this.qty = 1});

  // Per-line subtotal: unit price × quantity.
  double get lineTotal => (double.tryParse(item.price) ?? 0) * qty;
}

class CartModel extends ChangeNotifier {
  final List<CartLine> _lines = [];

  List<CartLine> get lines => List.unmodifiable(_lines);

  // Total number of physical items (sum of all quantities), not number of lines.
  // e.g. 2 cacti + 3 pots → itemCount = 5.
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.qty);

  // Number of distinct products (number of lines). Used for "X items" label.
  int get lineCount => _lines.length;

  bool get isEmpty => _lines.isEmpty;

  // Sum of all line totals — the cost of goods, before delivery.
  double get subtotal => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  // Items are grouped by name since CartItemModel has no unique id.
  // LIMITATION: two different products with the same name would merge into
  // one line. Add an `id` to CartItemModel if that ever becomes a problem.
  void addItem(CartItemModel item) {
    final existing = _findLine(item);
    if (existing != null) {
      existing.qty++;
    } else {
      _lines.add(CartLine(item: item));
    }
    notifyListeners();
  }

  void increment(CartItemModel item) {
    final line = _findLine(item);
    if (line != null) {
      line.qty++;
      notifyListeners();
    }
  }

  // Decrement removes the line entirely when qty hits 0.
  void decrement(CartItemModel item) {
    final line = _findLine(item);
    if (line == null) return;
    line.qty--;
    if (line.qty <= 0) {
      _lines.remove(line);
    }
    notifyListeners();
  }

  // Remove a whole line regardless of quantity (the ✕ button).
  void removeLine(CartItemModel item) {
    _lines.removeWhere((l) => l.item.name == item.name);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  CartLine? _findLine(CartItemModel item) {
    for (final line in _lines) {
      if (line.item.name == item.name) return line;
    }
    return null;
  }
}