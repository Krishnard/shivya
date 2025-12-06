class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> images;
  final double price;

  /// Optional compare-at price (for showing discounts)
  final double? compareAtPrice;

  /// Raw variants from Shopify:
  /// {
  ///   "id": String,
  ///   "title": String,
  ///   "price": double,
  ///   "compareAtPrice": double?
  /// }
  final List<Map<String, dynamic>> variants;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.images,
    required this.price,
    this.compareAtPrice,
    required this.variants,
  });

  /// Convenience getter used in UI to show a single image.
  /// This makes `product.imageUrl` work everywhere.
  String get imageUrl =>
      images.isNotEmpty ? images.first : '';

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      description: map["description"] ?? "",
      category: map["category"] ?? "General",
      images: List<String>.from(map["images"] ?? const []),
      price: (map["price"] as num?)?.toDouble() ?? 0.0,
      compareAtPrice: (map["compareAtPrice"] as num?)?.toDouble(),
      variants: (map["variants"] as List<dynamic>? ?? [])
          .map((v) => v as Map<String, dynamic>)
          .toList(),
    );
  }
}
