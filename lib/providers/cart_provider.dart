import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  // CART ITEMS
  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;

  void addToCart(Product product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  int get itemCount => _cartItems.length;

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.price);

  // CATEGORY FILTER
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
