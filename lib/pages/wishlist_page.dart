import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
// import '../models/product.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wish = Provider.of<WishlistProvider>(context);

    if (wish.wishlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Wishlist")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Your Wishlist is empty"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Shop Now"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: ListView.builder(
        itemCount: wish.wishlist.length,
        itemBuilder: (_, i) {
          final product = wish.wishlist[i];
          return ListTile(
            leading: Image.network(product.imageUrl),
            title: Text(product.name),
            subtitle: Text("₹${product.price}"),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () {
                Provider.of<CartProvider>(context, listen: false)
                    .addToCart(product);
              },
            ),
          );
        },
      ),
    );
  }
}
