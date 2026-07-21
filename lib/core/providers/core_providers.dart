import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan_ai/services/backup_service.dart';
import 'package:smartscan_ai/services/document_service.dart';
import 'package:smartscan_ai/services/ocr_service.dart';
import 'package:smartscan_ai/services/pdf_service.dart';
import 'package:smartscan_ai/services/scanner_service.dart';
import 'package:smartscan_ai/services/share_service.dart';
import 'package:smartscan_ai/repositories/document_repository.dart';
import 'package:smartscan_ai/repositories/folder_repository.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';
import 'package:smartscan_ai/repositories/settings_repository.dart';

/// Core dependency injection providers.
/// Provides singleton instances of repositories and services.

// Repositories
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository();
});

final pageRepositoryProvider = Provider<PageRepository>((ref) {
  return PageRepository();
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// Services
final documentServiceProvider = Provider<DocumentService>((ref) {
  return DocumentService();
});

final scannerServiceProvider = Provider<ScannerService>((ref) {
  return ScannerService();
});

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  return PdfService();
});

final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});
