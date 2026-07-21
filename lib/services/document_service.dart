import 'dart:io';
import 'package:smartscan_ai/core/utils/image_utils.dart';
import 'package:smartscan_ai/models/document_model.dart';
import 'package:smartscan_ai/repositories/document_repository.dart';
import 'package:smartscan_ai/repositories/page_repository.dart';
import 'package:uuid/uuid.dart';

/// Service encapsulating document business logic.
/// Coordinates between repositories and handles complex operations.
class DocumentService {
  static const _uuid = Uuid();

  final DocumentRepository _documentRepo;
  final PageRepository _pageRepo;

  DocumentService({
    DocumentRepository? documentRepo,
    PageRepository? pageRepo,
  })  : _documentRepo = documentRepo ?? DocumentRepository(),
        _pageRepo = pageRepo ?? PageRepository();

  /// Creates a new document with the given name.
  Future<DocumentModel> createDocument(String name) async {
    final now = DateTime.now();
    final document = DocumentModel(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
      pages: [],
      pageCount: 0,
    );

    await _documentRepo.insertDocument(document);
    return document;
  }

  /// Adds a scanned page to a document.
  Future<PageModel> addPage(
    String documentId,
    String imagePath,
  ) async {
    final nextPageNumber = await _pageRepo.getNextPageNumber(documentId);

    // Generate thumbnail
    final thumbnail = await ImageUtils.generateThumbnail(imagePath);

    final page = PageModel(
      id: _uuid.v4(),
      documentId: documentId,
      imagePath: imagePath,
      thumbnailPath: thumbnail.path,
      pageNumber: nextPageNumber,
      createdAt: DateTime.now(),
    );

    await _pageRepo.insertPage(page);

    // Update document page count and thumbnail
    final document = await _documentRepo.getDocument(documentId);
    if (document != null) {
      final pageCount = await _pageRepo.getPageCount(documentId);
      await _documentRepo.updateDocument(
        document.copyWith(
          pageCount: pageCount,
          thumbnailPath: nextPageNumber == 1 ? thumbnail.path : document.thumbnailPath,
          updatedAt: DateTime.now(),
        ),
      );
    }

    return page;
  }

  /// Gets a document with its pages loaded.
  Future<DocumentModel?> getDocumentWithPages(String documentId) async {
    final document = await _documentRepo.getDocument(documentId);
    if (document == null) return null;

    final pages = await _pageRepo.getPages(documentId);
    return document.copyWith(pages: pages);
  }

  /// Renames a document.
  Future<void> renameDocument(String documentId, String newName) async {
    final document = await _documentRepo.getDocument(documentId);
    if (document == null) return;

    await _documentRepo.updateDocument(
      document.copyWith(name: newName, updatedAt: DateTime.now()),
    );
  }

  /// Duplicates a document and all its pages.
  Future<DocumentModel?> duplicateDocument(String documentId) async {
    final original = await getDocumentWithPages(documentId);
    if (original == null) return null;

    final now = DateTime.now();
    final newDocument = DocumentModel(
      id: _uuid.v4(),
      name: '${original.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      pages: [],
      folderId: original.folderId,
      category: original.category,
      tags: original.tags,
      pageCount: original.pageCount,
    );

    await _documentRepo.insertDocument(newDocument);

    // Duplicate pages
    for (final page in original.pages) {
      final scansDir = await ImageUtils.getScansDirectoryPath();
      final newImagePath = '$scansDir/${ImageUtils.generateImageFileName()}';
      await ImageUtils.copyImage(page.imagePath, newImagePath);

      final thumbnail = await ImageUtils.generateThumbnail(newImagePath);

      final newPage = PageModel(
        id: _uuid.v4(),
        documentId: newDocument.id,
        imagePath: newImagePath,
        thumbnailPath: thumbnail.path,
        pageNumber: page.pageNumber,
        createdAt: now,
        ocrText: page.ocrText,
      );

      await _pageRepo.insertPage(newPage);
    }

    // Set thumbnail
    if (original.pages.isNotEmpty) {
      final firstPage = await _pageRepo.getPages(newDocument.id);
      if (firstPage.isNotEmpty) {
        await _documentRepo.updateDocument(
          newDocument.copyWith(thumbnailPath: firstPage.first.thumbnailPath),
        );
      }
    }

    return getDocumentWithPages(newDocument.id);
  }

  /// Deletes a document and all associated files.
  Future<void> deleteDocument(String documentId) async {
    final pages = await _pageRepo.getPages(documentId);

    // Delete all page image files
    for (final page in pages) {
      await ImageUtils.deleteImage(page.imagePath);
      if (page.thumbnailPath != null) {
        await ImageUtils.deleteImage(page.thumbnailPath!);
      }
    }

    // Delete pages from database
    await _pageRepo.deleteAllPages(documentId);

    // Delete document thumbnail
    final document = await _documentRepo.getDocument(documentId);
    if (document?.thumbnailPath != null) {
      await ImageUtils.deleteImage(document!.thumbnailPath!);
    }

    // Delete document from database
    await _documentRepo.deleteDocument(documentId);
  }

  /// Deletes a single page from a document.
  Future<void> deletePage(String documentId, String pageId) async {
    final page = await _pageRepo.getPage(pageId);
    if (page == null) return;

    // Delete image files
    await ImageUtils.deleteImage(page.imagePath);
    if (page.thumbnailPath != null) {
      await ImageUtils.deleteImage(page.thumbnailPath!);
    }

    // Delete page from database
    await _pageRepo.deletePage(pageId);

    // Update page count
    final pageCount = await _pageRepo.getPageCount(documentId);
    final document = await _documentRepo.getDocument(documentId);
    if (document != null) {
      await _documentRepo.updateDocument(
        document.copyWith(pageCount: pageCount, updatedAt: DateTime.now()),
      );
    }
  }

  /// Updates OCR text for a page and document.
  Future<void> updateOcrText(
    String documentId,
    String pageId,
    String ocrText,
  ) async {
    final page = await _pageRepo.getPage(pageId);
    if (page == null) return;

    await _pageRepo.updatePage(page.copyWith(ocrText: ocrText));

    // Aggregate OCR text for the document
    final pages = await _pageRepo.getPages(documentId);
    final fullOcrText = pages
        .where((p) => p.ocrText != null && p.ocrText!.isNotEmpty)
        .map((p) => p.ocrText!)
        .join('\n\n---\n\n');

    final document = await _documentRepo.getDocument(documentId);
    if (document != null) {
      await _documentRepo.updateDocument(
        document.copyWith(ocrText: fullOcrText, updatedAt: DateTime.now()),
      );
    }
  }

  /// Gets all documents.
  Future<List<DocumentModel>> getAllDocuments() async {
    return _documentRepo.getAllDocuments();
  }

  /// Gets recent documents.
  Future<List<DocumentModel>> getRecentDocuments({int limit = 10}) async {
    return _documentRepo.getRecentDocuments(limit: limit);
  }

  /// Searches documents.
  Future<List<DocumentModel>> searchDocuments(String query) async {
    return _documentRepo.searchDocuments(query);
  }

  /// Gets favorite documents.
  Future<List<DocumentModel>> getFavoriteDocuments() async {
    return _documentRepo.getFavoriteDocuments();
  }

  /// Toggles favorite status.
  Future<void> toggleFavorite(String documentId) async {
    final document = await _documentRepo.getDocument(documentId);
    if (document == null) return;
    await _documentRepo.toggleFavorite(documentId, !document.isFavorite);
  }
}
