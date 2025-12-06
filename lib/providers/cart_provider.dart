import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  /// List for UI
  List<CartItem> get cartItems => _items.values.toList();

  /// Total quantity for badge
  int get itemCount {
    int total = 0;
    for (final item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  /// Total price = sum(price * qty)
  double get totalPrice {
    double total = 0;
    for (var item in _items.values) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  bool isInCart(Product product) => _items.containsKey(product.id);

  /// Add product or increase quantity
  void addToCart(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity; // Increase quantity
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  /// Decrease quantity, remove if goes to 0
  void removeFromCart(Product product) {
    if (!_items.containsKey(product.id)) return;

    final item = _items[product.id]!;
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  /// Remove line completely
  void removeItemCompletely(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
