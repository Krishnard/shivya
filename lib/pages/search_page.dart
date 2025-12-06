import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../models/product.dart';
import '../pages/product_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);
    final List<Product> results = provider.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            provider.searchProducts(value);
          },
        ),
      ),
      body: results.isEmpty
          ? const Center(child: Text("No products found"))
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final p = results[i];
                return ListTile(
                  leading: Image.network(p.imageUrl, width: 50, height: 50),
                  title: Text(p.name),
                  subtitle: Text("₹${p.price}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailPage(product: p),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
