import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../pages/product_detail_page.dart';
import '../providers/wishlist_provider.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    if (productProvider.isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (productProvider.error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Error loading products:\n${productProvider.error}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    List<Product> products = productProvider.products;
    if (products.isEmpty) products = demoProducts;

    // 🔥 Category filter using selectedCategory
    final selectedCat = cartProvider.selectedCategory;
    products = products.where((product) {
      if (selectedCat == 'All') return true;

      final pc = product.category.toLowerCase();
      final sc = selectedCat.toLowerCase();

      // Match contains so "Gut & Liver Care" still matches "Gut & Liver"
      return pc.contains(sc);
    }).toList();

    if (products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No products found for this category.'),
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 600;
    final crossAxisCount = isWide ? 3 : 2;

    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = products[index];
          return _ProductCard(product: product);
        },
        childCount: products.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}



class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(product.imageUrl, fit: BoxFit.cover),
                  ),
                ),

                /// ❤️ Wishlist
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      alignment: Alignment.center,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        wishlistProvider.isInWishlist(product)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: Colors.red,
                      ),
                      onPressed: () => wishlistProvider.toggleWishlist(product),
                    ),
                  ),
                ),

                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade400,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Text(
                      'FLAT 20% OFF',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    '₹${product.price}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const Spacer(),

                  /// 🛒 Add to Cart
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      Provider.of<CartProvider>(context, listen: false)
                          .addToCart(product);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
