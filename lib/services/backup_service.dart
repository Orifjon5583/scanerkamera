import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_ai/core/constants/app_constants.dart';
import 'package:smartscan_ai/core/utils/file_utils.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/models/folder_model.dart';
import 'package:smartscan_ai/repositories/document_repository.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';
import 'package:smartscan_ai/repositories/folder_repository.dart';

/// Service for backup and restore operations.
/// Creates full backups of documents, pages, and settings.
class BackupService {
  final DocumentRepository _documentRepo;
  final PageRepository _pageRepo;
  final FolderRepository _folderRepo;

  BackupService({
    DocumentRepository? documentRepo,
    PageRepository? pageRepo,
    FolderRepository? folderRepo,
  })  : _documentRepo = documentRepo ?? DocumentRepository(),
        _pageRepo = pageRepo ?? PageRepository(),
        _folderRepo = folderRepo ?? FolderRepository();

  /// Creates a backup of all data.
  /// Returns the path to the backup directory.
  Future<String> createBackup() async {
    final appDir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupDir = Directory(
      '${appDir.path}/${AppConstants.backupDirectory}/backup_$timestamp',
    );
    await backupDir.create(recursive: true);

    // Export metadata
    final documents = await _documentRepo.getAllDocuments();
    final folders = await _folderRepo.getAllFolders();

    final metadata = <String, dynamic>{
      'version': AppConstants.appVersion,
      'created_at': DateTime.now().toIso8601String(),
      'document_count': documents.length,
      'folder_count': folders.length,
    };

    // Save documents metadata
    final documentsData = <Map<String, dynamic>>[];
    for (final doc in documents) {
      final pages = await _pageRepo.getPages(doc.id);
      documentsData.add({
        ...doc.toMap(),
        'pages': pages.map((p) => p.toMap()).toList(),
      });
    }

    // Save folders metadata
    final foldersData = folders.map((f) => f.toMap()).toList();

    // Write metadata file
    final metadataFile = File('${backupDir.path}/metadata.json');
    await metadataFile.writeAsString(jsonEncode({
      'metadata': metadata,
      'documents': documentsData,
      'folders': foldersData,
    }));

    // Copy image files
    final imagesDir = Directory('${backupDir.path}/images');
    await imagesDir.create();

    for (final doc in documents) {
      final pages = await _pageRepo.getPages(doc.id);
      for (final page in pages) {
        final imageFile = File(page.imagePath);
        if (await imageFile.exists()) {
          final fileName = page.imagePath.split('/').last;
          await imageFile.copy('${imagesDir.path}/$fileName');
        }
      }
    }

    return backupDir.path;
  }

  /// Restores from a backup directory.
  Future<bool> restoreBackup(String backupPath) async {
    try {
      final metadataFile = File('$backupPath/metadata.json');
      if (!await metadataFile.exists()) {
        return false;
      }

      final content = await metadataFile.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Restore folders
      final foldersData = data['folders'] as List<dynamic>;
      for (final folderMap in foldersData) {
        final folder = FolderModel.fromMap(folderMap as Map<String, dynamic>);
        await _folderRepo.insertFolder(folder);
      }

      // Restore documents and pages
      final documentsData = data['documents'] as List<dynamic>;
      for (final docMap in documentsData) {
        final docData = docMap as Map<String, dynamic>;
        final pagesData = docData['pages'] as List<dynamic>;
        docData.remove('pages');

        final document = DocumentModel.fromMap(docData);
        await _documentRepo.insertDocument(document);

        for (final pageMap in pagesData) {
          final page = PageModel.fromMap(pageMap as Map<String, dynamic>);
          await _pageRepo.insertPage(page);
        }
      }

      // Copy images back
      final imagesDir = Directory('$backupPath/images');
      if (await imagesDir.exists()) {
        final scansDir = await FileUtils.ensureDirectory(
          '${(await getApplicationDocumentsDirectory()).path}/${AppConstants.scansDirectory}',
        );
        await FileUtils.copyDirectory(imagesDir.path, scansDir.path);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gets the list of available backups.
  Future<List<BackupInfo>> getAvailableBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(
      '${appDir.path}/${AppConstants.backupDirectory}',
    );

    if (!await backupDir.exists()) return [];

    final backups = <BackupInfo>[];
    await for (final entity in backupDir.list()) {
      if (entity is Directory) {
        final metadataFile = File('${entity.path}/metadata.json');
        if (await metadataFile.exists()) {
          try {
            final content = await metadataFile.readAsString();
            final data = jsonDecode(content) as Map<String, dynamic>;
            final metadata = data['metadata'] as Map<String, dynamic>;

            backups.add(BackupInfo(
              path: entity.path,
              createdAt: DateTime.parse(metadata['created_at'] as String),
              documentCount: metadata['document_count'] as int,
              folderCount: metadata['folder_count'] as int,
            ));
          } catch (_) {
            // Skip invalid backups
          }
        }
      }
    }

    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// Deletes a backup.
  Future<void> deleteBackup(String backupPath) async {
    await FileUtils.deleteDirectory(backupPath);
  }
}

/// Information about a backup.
class BackupInfo {
  final String path;
  final DateTime createdAt;
  final int documentCount;
  final int folderCount;

  const BackupInfo({
    required this.path,
    required this.createdAt,
    required this.documentCount,
    required this.folderCount,
  });
}
