import 'product_variant.dart';

class Product {
  final String id; // 🔥 Needed for Shopify references
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.variants = const [],
  });
}

final List<Product> demoProducts = [
  Product(
    id: 'demo1',
    name: 'Dummy Herbal Immunity',
    price: 399.0,
    category: 'Immunity',
    imageUrl: 'https://m.media-amazon.com/images/I/71s+5vlaQtL._AC_SX679_.jpg',
  ),
];
