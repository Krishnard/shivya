import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
import '../shopify/shopify_service.dart';

class ProductProvider extends ChangeNotifier {
  final ShopifyService service = ShopifyService();

  List<Product> _allProducts = [];
  List<Product> products = [];
  List<Product> _searchResults = [];
  List<Product> get searchResults => _searchResults;

  List<String> categories = ["All"];

  String selectedCategory = "All";
  bool isLoading = false;
  String? error;

  /// Initial load: all products + combined categories (Collections + ProductType)
  Future<void> loadProducts() async {
    try {
      isLoading = true;
      notifyListeners();

      final raw = await service.fetchProducts();
      _allProducts = _mapToModel(raw);
      products = List.from(_allProducts);

      // Collections from Shopify
      final collections = await service.fetchCollections();

      // Product types from product data
      final productTypes = _allProducts
          .map((p) => p.category)
          .where((c) => c.trim().isNotEmpty)
          .toSet()
          .toList();

      // Option D: Merge collections + product types (no duplicates)
      final Set<String> cats = {"All", ...collections, ...productTypes};
      categories = cats.toList();

      error = null;
    } catch (e) {
      error = e.toString();
      print("❌ Error loading products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by category name
  Future<void> filterByCategory(String category) async {
    selectedCategory = category;
    notifyListeners();

    if (category == "All") {
      products = List.from(_allProducts);
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      // 1️⃣ Try by Shopify Collection title
      final raw = await service.fetchProductsByCollection(category);
      if (raw.isNotEmpty) {
        products = _mapToModel(raw);
      } else {
        // 2️⃣ Fallback: filter productType locally
        final lowerCat = category.toLowerCase();
        products = _allProducts.where((p) {
          final pc = p.category.toLowerCase();
          return pc == lowerCat || pc.contains(lowerCat);
        }).toList();
      }

      error = null;
    } catch (e) {
      error = e.toString();
      print("❌ Category filter error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Search across all products (not only filtered list)
  void searchProducts(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      final lower = query.toLowerCase();
      _searchResults = _allProducts.where((p) {
        return p.name.toLowerCase().contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  /// Map DTO maps from ShopifyService → Product model
  // List<Product> _mapToModel(List rawProducts) {
  //   return rawProducts.map<Product>((p) {
  //     final List<ProductVariant> variants =
  //         (p["variants"] as List<ProductVariant>? ?? <ProductVariant>[]);

  //     final double price =
  //         variants.isNotEmpty ? variants.first.price : (p["price"] ?? 0.0);

  //     return Product(
  //       id: p["id"] as String,
  //       name: p["name"] as String,
  //       imageUrl: p["imageUrl"] as String,
  //       price: price,
  //       category: (p["category"] ?? "Other") as String,
  //       compareAtPrice:
  //           variants.isNotEmpty ? variants.first.compareAtPrice : null,
  //       variants: variants,
  //       isSpotlight: (p["isSpotlight"] ?? false) as bool,
  //       offerText: p["offerText"] as String?,
  //       badgeText: p["badgeText"] as String?,
  //       longDescription: p["longDescription"] as String?,
  //       howToUse: p["howToUse"] as String?,
  //     );
  //   }).toList();
  // }

  // List<Product> _mapToModel(List raw) {
  //   return raw.map((p) {
  //     return Product(
  //       id: p["id"],
  //       name: p["name"],
  //       category: p["category"],
  //       imageUrl: p["imageUrl"],
  //       price: p["price"] ?? 0.0,
  //       variants: p["variants"],
  //       offerText: p["offerText"],
  //       badgeText: p["badgeText"],
  //       isSpotlight: p["isSpotlight"] ?? false,
  //     );
  //   }).toList();
  // }

  List<Product> _mapToModel(List raw) {
    return raw.map((p) => Product.fromMap(p)).toList();
  }
}
