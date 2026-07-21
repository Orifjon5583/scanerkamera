import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/core/utils/date_utils.dart';
import 'package:smartscan_ai/features/home/providers/home_provider.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';
import 'package:smartscan_ai/services/document_service.dart';

/// Detail screen showing all pages of a document with management actions.
class DocumentDetailScreen extends ConsumerStatefulWidget {
  final DocumentModel document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  ConsumerState<DocumentDetailScreen> createState() =>
      _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends ConsumerState<DocumentDetailScreen> {
  late DocumentModel _document;
  List<PageModel> _pages = [];
  bool _isLoading = true;
  final PageRepository _pageRepo = PageRepository();
  final DocumentService _documentService = DocumentService();

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _loadPages();
  }

  Future<void> _loadPages() async {
    setState(() => _isLoading = true);
    final pages = await _pageRepo.getPages(_document.id);
    setState(() {
      _pages = pages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_document.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Rename'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: ListTile(
                  leading: Icon(Icons.copy_outlined),
                  title: Text('Duplicate'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'favorite',
                child: ListTile(
                  leading: Icon(Icons.star_outline),
                  title: Text('Toggle Favorite'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'share_images',
                child: ListTile(
                  leading: Icon(Icons.image_outlined),
                  title: Text('Share Images'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Document info header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_pages.length} ${_pages.length == 1 ? 'page' : 'pages'}',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              'Created ${AppDateUtils.formatDate(_document.createdAt)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quick actions
                      IconButton(
                        icon: const Icon(Icons.text_fields_rounded),
                        onPressed: _pages.isNotEmpty
                            ? () => _openOcr(_pages.first.imagePath)
                            : null,
                        tooltip: 'OCR',
                      ),
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        onPressed: () => _openPdfExport(),
                        tooltip: 'Export PDF',
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Pages grid
                Expanded(
                  child: _pages.isEmpty
                      ? Center(
                          child: Text(
                            'No pages in this document',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _pages.length,
                          itemBuilder: (context, index) {
                            final page = _pages[index];
                            return _PageCard(
                              page: page,
                              onTap: () => _viewPage(page),
                              onOcr: () => _openOcr(page.imagePath),
                              onDelete: () => _deletePage(page),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addMorePages(),
        child: const Icon(Icons.add_a_photo_rounded),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'rename':
        await _renameDocument();
        break;
      case 'duplicate':
        await _duplicateDocument();
        break;
      case 'favorite':
        await _documentService.toggleFavorite(_document.id);
        ref.read(homeNotifierProvider.notifier).refresh();
        break;
      case 'share_images':
        await _shareImages();
        break;
      case 'delete':
        await _deleteDocument();
        break;
    }
  }

  Future<void> _renameDocument() async {
    final controller = TextEditingController(text: _document.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Document name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _documentService.renameDocument(_document.id, newName);
      setState(() {
        _document = _document.copyWith(name: newName);
      });
      ref.read(homeNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _duplicateDocument() async {
    await _documentService.duplicateDocument(_document.id);
    ref.read(homeNotifierProvider.notifier).refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document duplicated')),
      );
    }
  }

  Future<void> _shareImages() async {
    if (_pages.isEmpty) return;
    final xFiles = _pages.map((p) => XFile(p.imagePath)).toList();
    await Share.shareXFiles(xFiles, subject: _document.name);
  }

  Future<void> _deleteDocument() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _documentService.deleteDocument(_document.id);
      ref.read(homeNotifierProvider.notifier).refresh();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _deletePage(PageModel page) async {
    await _documentService.deletePage(_document.id, page.id);
    await _loadPages();
  }

  void _viewPage(PageModel page) {
    // Show full-screen image viewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imagePath: page.imagePath,
          pageNumber: page.pageNumber,
        ),
      ),
    );
  }

  void _openOcr(String imagePath) {
    Navigator.pushNamed(context, AppRouter.ocr, arguments: imagePath);
  }

  void _openPdfExport() {
    Navigator.pushNamed(
      context,
      AppRouter.pdfPreview,
      arguments: _document,
    );
  }

  void _addMorePages() {
    Navigator.pushNamed(
      context,
      AppRouter.scanner,
      arguments: _document.id,
    );
  }
}

/// Card widget for individual page display.
class _PageCard extends StatelessWidget {
  final PageModel page;
  final VoidCallback onTap;
  final VoidCallback onOcr;
  final VoidCallback onDelete;

  const _PageCard({
    required this.page,
    required this.onTap,
    required this.onOcr,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.file(
                  File(page.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.broken_image,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Text(
                    'Page ${page.pageNumber}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onOcr,
                    child: Icon(
                      Icons.text_fields,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen image viewer for page detail.
class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final int pageNumber;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.pageNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Page $pageNumber'),
      ),
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5.0,
        child: Center(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image,
              size: 64,
              color: Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}
