import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};

  Map<String, int> get items => _items;

  void add(Product product) {
    _items[product.id] = (_items[product.id] ?? 0) + 1;
    notifyListeners();
  }

  void remove(Product product) {
    if (_items[product.id] != null && _items[product.id]! > 0) {
      _items[product.id] = _items[product.id]! - 1;
      if (_items[product.id] == 0) _items.remove(product.id);
      notifyListeners();
    }
  }

  int getQuantity(Product product) => _items[product.id] ?? 0;

  int get totalItems => _items.values.fold(0, (a, b) => a + b);
}
