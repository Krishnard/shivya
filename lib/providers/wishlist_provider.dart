import 'package:flutter/foundation.dart';
import '../models/product.dart';

class WishlistProvider extends ChangeNotifier {
  final List<Product> _wishlist = [];
  List<Product> get wishlist => _wishlist;

  void toggleWishlist(Product product) {
    if (_wishlist.contains(product)) {
      _wishlist.remove(product);
    } else {
      _wishlist.add(product);
    }
    notifyListeners();
  }

  bool isInWishlist(Product product) {
    return _wishlist.contains(product);
  }

  int get itemCount => _wishlist.length;
}
