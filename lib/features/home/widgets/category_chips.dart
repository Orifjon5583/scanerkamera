import 'package:flutter/material.dart';

/// Horizontal scrolling category filter chips.
class CategoryChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    ('All', Icons.all_inclusive_rounded),
    ('Recent', Icons.access_time_rounded),
    ('Favorites', Icons.star_rounded),
    ('Documents', Icons.description_outlined),
    ('Receipts', Icons.receipt_long_outlined),
    ('ID Cards', Icons.badge_outlined),
    ('Notes', Icons.note_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, icon) = _categories[index];
          final isSelected = (selectedCategory == null && index == 0) ||
              selectedCategory == label;

          return FilterChip(
            label: Text(label),
            avatar: Icon(icon, size: 18),
            selected: isSelected,
            onSelected: (_) {
              onCategorySelected(index == 0 ? null : label);
            },
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          );
        },
      ),
    );
  }
}
