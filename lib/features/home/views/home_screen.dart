import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/core/theme/app_colors.dart';
import 'package:smartscan_ai/features/home/providers/home_provider.dart';
import 'package:smartscan_ai/features/home/widgets/document_grid_item.dart';
import 'package:smartscan_ai/features/home/widgets/document_list_item.dart';
import 'package:smartscan_ai/features/home/widgets/home_search_bar.dart';
import 'package:smartscan_ai/features/home/widgets/category_chips.dart';
import 'package:smartscan_ai/features/home/widgets/empty_state_widget.dart';
import 'package:smartscan_ai/models/document_model.dart';

/// Main home screen displaying documents, search, and navigation.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen loads
    Future.microtask(() {
      ref.read(homeNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final viewMode = ref.watch(viewModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // App bar with title and actions
              SliverAppBar(
                floating: true,
                title: Text(
                  'SmartScan AI',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  // View mode toggle
                  IconButton(
                    icon: Icon(
                      viewMode == ViewMode.grid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                    ),
                    onPressed: () {
                      ref.read(viewModeProvider.notifier).state =
                          viewMode == ViewMode.grid
                              ? ViewMode.list
                              : ViewMode.grid;
                    },
                    tooltip: viewMode == ViewMode.grid
                        ? 'Switch to list view'
                        : 'Switch to grid view',
                  ),
                  // Settings
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.settings);
                    },
                    tooltip: 'Settings',
                  ),
                ],
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: HomeSearchBar(
                    onSearch: (query) {
                      ref.read(homeNotifierProvider.notifier).search(query);
                    },
                  ),
                ),
              ),

              // Category filter chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CategoryChips(
                    selectedCategory: ref.watch(selectedCategoryProvider),
                    onCategorySelected: (category) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Content
              if (homeState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (homeState.documents.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(),
                )
              else
                _buildDocumentsList(homeState, viewMode),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRouter.scanner);
          // Refresh after returning from scanner
          ref.read(homeNotifierProvider.notifier).refresh();
        },
        icon: const Icon(Icons.document_scanner_rounded),
        label: const Text('Scan'),
      ),
    );
  }

  /// Builds the documents list based on view mode.
  Widget _buildDocumentsList(HomeState homeState, ViewMode viewMode) {
    final documents = homeState.searchResults.isNotEmpty
        ? homeState.searchResults
        : homeState.documents;

    if (viewMode == ViewMode.grid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final document = documents[index];
              return DocumentGridItem(
                document: document,
                onTap: () => _openDocument(document),
                onFavorite: () => _toggleFavorite(document.id),
                onDelete: () => _deleteDocument(document.id),
              );
            },
            childCount: documents.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final document = documents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DocumentListItem(
                document: document,
                onTap: () => _openDocument(document),
                onFavorite: () => _toggleFavorite(document.id),
                onDelete: () => _deleteDocument(document.id),
              ),
            );
          },
          childCount: documents.length,
        ),
      ),
    );
  }

  void _openDocument(DocumentModel document) {
    Navigator.pushNamed(
      context,
      AppRouter.documentDetail,
      arguments: document,
    );
  }

  void _toggleFavorite(String documentId) {
    ref.read(homeNotifierProvider.notifier).toggleFavorite(documentId);
  }

  Future<void> _deleteDocument(String documentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text(
          'Are you sure you want to delete this document? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(homeNotifierProvider.notifier).deleteDocument(documentId);
    }
  }
}
