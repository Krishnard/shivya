import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // --- EMPTY STATE UI ---
    if (cart.cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Cart')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Your cart is empty",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // go back to previous (Home)
                },
                child: const Text("Shop Now"),
              ),
            ],
          ),
        ),
      );
    }

    // 📌 PRICE CALCULATIONS
    final subtotal = cart.totalPrice;
    final discount = subtotal * 0.10; // 10% discount for now
    final total = subtotal - discount;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Column(
        children: [
          // --- CART ITEMS LIST ---
          Expanded(
            child: ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                final CartItem item = cart.cartItems[index];
                final Product product = item.product;
                final int qty = item.quantity;
                final double lineTotal = product.price * qty;

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, size: 20),
                      ),
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                    '₹${product.price.toStringAsFixed(0)} x $qty = ₹${lineTotal.toStringAsFixed(0)}',
                  ),

                  // Qty +/- + delete
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          cart.removeFromCart(product);
                        },
                      ),
                      Text(
                        qty.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          cart.addToCart(product);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          cart.removeItemCompletely(product);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // --- PRICE SUMMARY BOX ---
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                  color: Colors.black.withOpacity(0.08),
                ),
              ],
            ),
            child: Column(
              children: [
                _priceRow("Subtotal", subtotal),
                _priceRow("Discount (10%)", -discount),
                const Divider(),
                _priceRow("Total Payable", total, bold: true),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      // 🔹 Direct checkout without app login
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      final items = cart.cartItems;

                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your cart is empty')),
                        );
                        return;
                      }

                      final parts = <String>[];

                      for (final item in items) {
                        final product = item.product;
                        final variantIdRaw = _getVariantIdForCart(product);
                        if (variantIdRaw == null || variantIdRaw.isEmpty) {
                          continue;
                        }

                        final variantId = _normalizeShopifyId(variantIdRaw);
                        final qty = item.quantity;
                        if (qty <= 0) continue;

                        parts.add('$variantId:$qty');
                      }

                      if (parts.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not build checkout link.'),
                          ),
                        );
                        return;
                      }

                      final uri = Uri.parse(
                        'https://shivyahealthcare.com/cart/${parts.join(',')}',
                      );

                      final ok = await launchUrl(
                        uri,
                        mode: LaunchMode.inAppBrowserView,
                      );

                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open checkout.'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Checkout",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PRICE DISPLAY ROW ---
  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          "₹${amount.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────
  // Shopify checkout helpers
  // ───────────────────────────────────────────────────────────────

  String _normalizeShopifyId(String id) {
    // "gid://shopify/ProductVariant/1234567890" -> "1234567890"
    if (id.startsWith('gid://')) {
      return id.split('/').last;
    }
    return id;
  }

  /// Decide which variant ID to use for checkout.
  /// Right now: first variant if available, else fall back to product.id
  String? _getVariantIdForCart(Product product) {
    try {
      if (product.variants.isNotEmpty) {
        final v = product.variants.first;
        final id = (v['id'] as String?) ?? '';
        if (id.isNotEmpty) {
          return id;
        }
      }
    } catch (_) {
      // ignore and fall back below
    }

    // fallback – sometimes product.id may already be a variant id
    return product.id.isNotEmpty ? product.id : null;
  }
}
