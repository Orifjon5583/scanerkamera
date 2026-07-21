import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/services/pdf_service.dart';

/// Provider for the PDF service instance.
final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});
