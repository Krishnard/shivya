import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../shopify/shopify_service.dart';

class ProductProvider extends ChangeNotifier {
  final ShopifyService service = ShopifyService();

  List<Product> products = [];
  bool isLoading = false;
  String? error;
  List<String> categories = ['All'];

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      final shopifyData = await service.fetchProducts();

      products = shopifyData.map((map) {
        final variants = map['variants'] as List<ProductVariant>;
        final double basePrice =
            variants.isNotEmpty ? variants.first.price : (map['price'] as double);

        return Product(
          id: map['id'],
          name: map['name'],
          imageUrl: map['imageUrl'],
          price: basePrice,
          category: map['category'],
          variants: variants,
        );
      }).toList();

      // collections loading stays as you had earlier...
      // categories = ['All', ...collectionTitles];

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
