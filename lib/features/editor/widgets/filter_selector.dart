import 'package:flutter/material.dart';
import 'package:smartscan_ai/core/theme/app_colors.dart';
import 'package:smartscan_ai/features/editor/providers/editor_provider.dart';

/// Horizontal scrolling filter selector widget.
/// Displays filter previews that users can tap to apply.
class FilterSelector extends StatefulWidget {
  final ValueChanged<ImageFilter> onFilterSelected;

  const FilterSelector({super.key, required this.onFilterSelected});

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  ImageFilter _selectedFilter = ImageFilter.original;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: ImageFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
              widget.onFilterSelected(filter);
            },
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getFilterColor(filter),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      _getFilterIcon(filter),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getFilterName(filter),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getFilterColor(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.original:
        return AppColors.filterOriginal;
      case ImageFilter.blackAndWhite:
        return AppColors.filterBW;
      case ImageFilter.grayscale:
        return AppColors.filterGray;
      case ImageFilter.magic:
        return AppColors.filterMagic;
      case ImageFilter.sharpen:
        return AppColors.info;
    }
  }

  IconData _getFilterIcon(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.original:
        return Icons.image_outlined;
      case ImageFilter.blackAndWhite:
        return Icons.contrast;
      case ImageFilter.grayscale:
        return Icons.filter_b_and_w;
      case ImageFilter.magic:
        return Icons.auto_fix_high;
      case ImageFilter.sharpen:
        return Icons.deblur;
    }
  }

  String _getFilterName(ImageFilter filter) {
    switch (filter) {
      case ImageFilter.original:
        return 'Original';
      case ImageFilter.blackAndWhite:
        return 'B&W';
      case ImageFilter.grayscale:
        return 'Grayscale';
      case ImageFilter.magic:
        return 'Magic';
      case ImageFilter.sharpen:
        return 'Sharpen';
    }
  }
}
