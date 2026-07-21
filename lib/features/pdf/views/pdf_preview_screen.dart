import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';
import 'package:smartscan_ai/services/pdf_service.dart';

/// PDF preview and export screen.
/// Allows users to generate, share, and print PDF documents.
class PdfPreviewScreen extends ConsumerStatefulWidget {
  final DocumentModel document;

  const PdfPreviewScreen({super.key, required this.document});

  @override
  ConsumerState<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends ConsumerState<PdfPreviewScreen> {
  bool _isGenerating = false;
  String? _generatedPdfPath;
  final PdfService _pdfService = PdfService();
  final PageRepository _pageRepo = PageRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          if (_generatedPdfPath != null) ...[
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _sharePdf(),
              tooltip: 'Share PDF',
            ),
            IconButton(
              icon: const Icon(Icons.print_outlined),
              onPressed: () => _printPdf(),
              tooltip: 'Print',
            ),
          ],
        ],
      ),
      body: _isGenerating
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            )
          : _buildContent(theme),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Document info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.document.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.document.pageCount} ${widget.document.pageCount == 1 ? 'page' : 'pages'}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Export options
          Text(
            'Export Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // High quality PDF
          _ExportOption(
            icon: Icons.high_quality_outlined,
            title: 'High Quality PDF',
            subtitle: 'Best for printing and archival',
            onTap: () => _generatePdf(quality: 0.95),
          ),

          const SizedBox(height: 8),

          // Compressed PDF
          _ExportOption(
            icon: Icons.compress_outlined,
            title: 'Compressed PDF',
            subtitle: 'Smaller file size for sharing',
            onTap: () => _generatePdf(quality: 0.5),
          ),

          const SizedBox(height: 8),

          // Export as images
          _ExportOption(
            icon: Icons.image_outlined,
            title: 'Export as Images',
            subtitle: 'Save individual page images',
            onTap: () => _exportImages(),
          ),

          const Spacer(),

          // Status
          if (_generatedPdfPath != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PDF generated successfully',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _generatePdf({double quality = 0.85}) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final pages = await _pageRepo.getPages(widget.document.id);
      final pdfPath = await _pdfService.generatePdf(
        widget.document,
        pages,
        quality: quality,
      );

      setState(() {
        _isGenerating = false;
        _generatedPdfPath = pdfPath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_generatedPdfPath == null) return;
    await Share.shareXFiles(
      [XFile(_generatedPdfPath!)],
      subject: widget.document.name,
    );
  }

  Future<void> _printPdf() async {
    if (_generatedPdfPath == null) return;
    try {
      await _pdfService.printPdf(_generatedPdfPath!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  Future<void> _exportImages() async {
    final pages = await _pageRepo.getPages(widget.document.id);
    final imagePaths = pages.map((p) => p.imagePath).toList();

    if (imagePaths.isNotEmpty) {
      await Share.shareXFiles(
        imagePaths.map((path) => XFile(path)).toList(),
        subject: '${widget.document.name} - Images',
      );
    }
  }
}

/// Export option card widget.
class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
