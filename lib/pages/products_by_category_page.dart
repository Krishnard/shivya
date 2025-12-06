import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';

class ProductsByCategoryPage extends StatelessWidget {
  final String category;

  const ProductsByCategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    // Ensure products for this category are loaded
    // (if you already filter before navigating, this still works safely)
    if (productProvider.selectedCategory != category) {
      productProvider.filterByCategory(category);
    }

    final bool loading = productProvider.isLoading;
    final List<Product> products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(
                  child: Text(
                    "No products found in this category.",
                    style: TextStyle(fontSize: 14),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    itemCount: products.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (_, index) {
                      final p = products[index];
                      return _CategoryProductCard(product: p);
                    },
                  ),
                ),
    );
  }
}

class _CategoryProductCard extends StatelessWidget {
  final Product product;
  const _CategoryProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlist = Provider.of<WishlistProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final cs = Theme.of(context).colorScheme;

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
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // image + wishlist + tag
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          wishlist.isInWishlist(product)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color: Colors.pink,
                        ),
                        onPressed: () {
                          wishlist.toggleWishlist(product);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    cart.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart!'),
                        duration: const Duration(milliseconds: 900),
                      ),
                    );
                  },
                  child: const Text("Add to Cart"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
