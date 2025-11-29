class ProductVariant {
  final String id;
  final String title;
  final double price;
  final double? compareAtPrice;

  const ProductVariant({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
  });
}
