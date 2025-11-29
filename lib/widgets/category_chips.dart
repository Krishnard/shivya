import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';


class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  final List<String> _categories = const [
    'All',
    'Ayurveda',
    'Immunity',
    'Pain Relief',
    'Skin Care',
    'Hair Care',
    'Digestive',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final label = _categories[index];
          final selected = index == 0;

          return FilterChip(
            selected: selected,
            label: Text(label),
            onSelected: (_) {
              Provider.of<CartProvider>(context, listen: false)
                  .selectCategory(label);
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _categories.length,
      ),
    );
  }
}
