import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import 'login_page.dart';
import '../providers/auth_provider.dart';

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
                  Navigator.pop(context); // go back to home
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
                final Product product = cart.cartItems[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      product.imageUrl,
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text('₹${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => cart.removeFromCart(product),
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
                    onPressed: () {
                      final auth = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (!auth.isLoggedIn) {
                        // force login before checkout
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                        return;
                      }

                      // TODO: proceed to real checkout later
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Checkout coming soon!")),
                      );
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
}
