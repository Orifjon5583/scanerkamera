import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/services/pdf_service.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';

/// Service for sharing documents via various channels.
class ShareService {
  final PdfService _pdfService;
  final PageRepository _pageRepo;

  ShareService({
    PdfService? pdfService,
    PageRepository? pageRepo,
  })  : _pdfService = pdfService ?? PdfService(),
        _pageRepo = pageRepo ?? PageRepository();

  /// Shares a document as PDF.
  Future<void> shareAsPdf(DocumentModel document) async {
    final pages = await _pageRepo.getPages(document.id);
    final pdfPath = await _pdfService.generatePdf(document, pages);

    await Share.shareXFiles(
      [XFile(pdfPath)],
      subject: document.name,
      text: 'Shared from SmartScan AI',
    );
  }

  /// Shares document pages as individual images.
  Future<void> shareAsImages(DocumentModel document) async {
    final pages = await _pageRepo.getPages(document.id);
    final xFiles = pages
        .where((p) => File(p.imagePath).existsSync())
        .map((p) => XFile(p.imagePath))
        .toList();

    if (xFiles.isEmpty) return;

    await Share.shareXFiles(
      xFiles,
      subject: document.name,
      text: 'Shared from SmartScan AI',
    );
  }

  /// Shares OCR text.
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(
      text,
      subject: subject ?? 'Text from SmartScan AI',
    );
  }

  /// Shares a single image file.
  Future<void> shareImage(String imagePath) async {
    final file = File(imagePath);
    if (!await file.exists()) return;

    await Share.shareXFiles(
      [XFile(imagePath)],
      text: 'Shared from SmartScan AI',
    );
  }
}
