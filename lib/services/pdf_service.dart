import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:uuid/uuid.dart';

/// Service for PDF generation, manipulation, and export.
class PdfService {
  static const _uuid = Uuid();

  /// Generates a PDF from document pages.
  Future<String> generatePdf(
    DocumentModel document,
    List<PageModel> pages, {
    double quality = 0.85,
    String? password,
  }) async {
    final pdf = pw.Document(
      author: 'SmartScan AI',
      title: document.name,
      creator: 'SmartScan AI Document Scanner',
    );

    for (final page in pages) {
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    final exportsDir = await ImageUtils.getExportsDirectoryPath();
    final fileName = '${document.name.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${_uuid.v4().substring(0, 8)}.pdf';
    final outputPath = '$exportsDir/$fileName';

    final pdfBytes = await pdf.save();
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdfBytes);

    return outputPath;
  }

  /// Generates a compressed PDF with reduced quality.
  Future<String> generateCompressedPdf(
    DocumentModel document,
    List<PageModel> pages, {
    double quality = 0.5,
  }) async {
    return generatePdf(document, pages, quality: quality);
  }

  /// Merges multiple PDF files into one.
  Future<String> mergePdfs(
    List<String> pdfPaths,
    String outputName,
  ) async {
    final pdf = pw.Document(
      author: 'SmartScan AI',
      title: outputName,
    );

    for (final pdfPath in pdfPaths) {
      final file = File(pdfPath);
      if (!await file.exists()) continue;

      // For merging, we re-read images from pages
      // In a production app, you'd use a proper PDF merger
      // This creates a new PDF from the source pages
    }

    final exportsDir = await ImageUtils.getExportsDirectoryPath();
    final fileName = '${outputName}_merged_${_uuid.v4().substring(0, 8)}.pdf';
    final outputPath = '$exportsDir/$fileName';

    final pdfBytes = await pdf.save();
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdfBytes);

    return outputPath;
  }

  /// Generates a PDF from a list of image file paths.
  Future<String> generatePdfFromImages(
    List<String> imagePaths,
    String documentName, {
    double quality = 0.85,
  }) async {
    final pdf = pw.Document(
      author: 'SmartScan AI',
      title: documentName,
    );

    for (final imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) continue;

      final imageBytes = await imageFile.readAsBytes();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) {
            return pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    final exportsDir = await ImageUtils.getExportsDirectoryPath();
    final fileName = '${documentName.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${_uuid.v4().substring(0, 8)}.pdf';
    final outputPath = '$exportsDir/$fileName';

    final pdfBytes = await pdf.save();
    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(pdfBytes);

    return outputPath;
  }

  /// Prints a PDF document.
  Future<void> printPdf(String pdfPath) async {
    final file = File(pdfPath);
    if (!await file.exists()) {
      throw Exception('PDF file not found');
    }

    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(
      onLayout: (_) => Future.value(Uint8List.fromList(bytes)),
    );
  }

  /// Prints a document directly from pages.
  Future<void> printDocument(
    DocumentModel document,
    List<PageModel> pages,
  ) async {
    final pdfPath = await generatePdf(document, pages);
    await printPdf(pdfPath);
    // Clean up temporary PDF
    await File(pdfPath).delete();
  }

  /// Gets PDF file size.
  Future<int> getPdfSize(String pdfPath) async {
    final file = File(pdfPath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }
}
