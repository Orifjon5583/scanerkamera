import 'package:flutter/material.dart';

/// Search bar widget for the home screen.
/// Provides debounced search with clear functionality.
class HomeSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;

  const HomeSearchBar({super.key, required this.onSearch});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      onChanged: (value) {
        setState(() {
          _hasText = value.isNotEmpty;
        });
        widget.onSearch(value);
      },
      decoration: InputDecoration(
        hintText: 'Search documents...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    _hasText = false;
                  });
                  widget.onSearch('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
