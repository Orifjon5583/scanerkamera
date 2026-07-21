import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/core/router/app_router.dart';
import 'package:smartscan_ai/features/home/providers/home_provider.dart';
import 'package:smartscan_ai/features/home/widgets/document_list_item.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/repositories/document_repository.dart';

/// Screen displaying documents within a specific folder.
class FolderScreen extends ConsumerStatefulWidget {
  final String folderName;

  const FolderScreen({super.key, required this.folderName});

  @override
  ConsumerState<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends ConsumerState<FolderScreen> {
  List<DocumentModel> _documents = [];
  bool _isLoading = true;
  final DocumentRepository _documentRepo = DocumentRepository();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    // Load documents for this folder
    final allDocs = await _documentRepo.getAllDocuments();
    final folderDocs = allDocs.where((d) => d.folderId == widget.folderName).toList();
    setState(() {
      _documents = folderDocs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Empty Folder',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No documents in this folder yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final document = _documents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DocumentListItem(
                        document: document,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.documentDetail,
                            arguments: document,
                          );
                        },
                        onFavorite: () {
                          ref
                              .read(homeNotifierProvider.notifier)
                              .toggleFavorite(document.id);
                        },
                        onDelete: () {
                          ref
                              .read(homeNotifierProvider.notifier)
                              .deleteDocument(document.id);
                          _loadDocuments();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
