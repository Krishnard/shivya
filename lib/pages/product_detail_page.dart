import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/product_variant.dart';
import '../providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _selectedVariantIndex = 0;

  ProductVariant? get _selectedVariant {
    final vars = widget.product.variants;
    if (vars.isEmpty) return null;
    if (_selectedVariantIndex >= vars.length) return vars.first;
    return vars[_selectedVariantIndex];
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final selectedVariant = _selectedVariant;

    final price = selectedVariant?.price ?? product.price;
    final compareAt = selectedVariant?.compareAtPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  product.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),

                // Variants selector
                if (product.variants.isNotEmpty) ...[
                  const Text(
                    "Select Variant",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.variants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final v = product.variants[index];
                        final bool isSelected =
                            index == _selectedVariantIndex;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedVariantIndex = index);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: isSelected
                                  ? Colors.green.shade700
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green.shade700
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              v.title.isEmpty ? "Option ${index + 1}" : v.title,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Price
                Row(
                  children: [
                    Text(
                      "₹${price.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (compareAt != null && compareAt > price)
                      Text(
                        "₹${compareAt.toStringAsFixed(0)}",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  "Product details & usage coming soon...",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),

          // Bottom Add to Cart
          SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    final cart = Provider.of<CartProvider>(context,
                        listen: false);

                    // Make a cart-specific Product that reflects variant choice
                    final v = selectedVariant;
                    final cartProduct = Product(
                      id: v?.id ?? product.id,
                      name: v == null
                          ? product.name
                          : "${product.name} (${v.title})",
                      imageUrl: product.imageUrl,
                      price: price,
                      category: product.category,
                    );

                    cart.addToCart(cartProduct);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to cart")),
                    );
                  },
                  child: const Text("Add to Cart"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
