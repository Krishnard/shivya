import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = productProvider.categories;
    final selected = productProvider.selectedCategory;

    if (productProvider.isLoading && categories.length <= 1) {
      return const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final label = categories[index];
          final isSelected = selected == label;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            selectedColor: Colors.green.shade600,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.green),
            onSelected: (_) {
              productProvider.filterByCategory(label);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
      ),
    );
  }
}
