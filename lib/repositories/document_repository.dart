import 'package:smartscan_ai/core/services/database_service.dart';
import 'package:smartscan_ai/models/document_model.dart';

/// Repository for document CRUD operations.
/// Abstracts database access for document entities.
class DocumentRepository {
  final DatabaseService _dbService;

  DocumentRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  /// Retrieves all documents ordered by most recent.
  Future<List<DocumentModel>> getAllDocuments() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'documents',
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  /// Retrieves a single document by ID.
  Future<DocumentModel?> getDocument(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DocumentModel.fromMap(maps.first);
  }

  /// Retrieves documents in a specific folder.
  Future<List<DocumentModel>> getDocumentsByFolder(String folderId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'documents',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  /// Retrieves favorited documents.
  Future<List<DocumentModel>> getFavoriteDocuments() async {
    final db = await _dbService.database;
    final maps = await db.query(
      'documents',
      where: 'is_favorite = 1',
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  /// Searches documents by name or OCR text.
  Future<List<DocumentModel>> searchDocuments(String query) async {
    final db = await _dbService.database;
    final searchTerm = '%$query%';
    final maps = await db.query(
      'documents',
      where: 'name LIKE ? OR ocr_text LIKE ? OR tags LIKE ?',
      whereArgs: [searchTerm, searchTerm, searchTerm],
      orderBy: 'updated_at DESC',
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  /// Retrieves recent documents (limited count).
  Future<List<DocumentModel>> getRecentDocuments({int limit = 10}) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'documents',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return maps.map((map) => DocumentModel.fromMap(map)).toList();
  }

  /// Inserts a new document.
  Future<void> insertDocument(DocumentModel document) async {
    final db = await _dbService.database;
    await db.insert('documents', document.toMap());
  }

  /// Updates an existing document.
  Future<void> updateDocument(DocumentModel document) async {
    final db = await _dbService.database;
    await db.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  /// Deletes a document by ID.
  Future<void> deleteDocument(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Toggles the favorite status of a document.
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _dbService.database;
    await db.update(
      'documents',
      {'is_favorite': isFavorite ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Moves a document to a folder.
  Future<void> moveToFolder(String documentId, String? folderId) async {
    final db = await _dbService.database;
    await db.update(
      'documents',
      {'folder_id': folderId, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [documentId],
    );
  }

  /// Gets the total document count.
  Future<int> getDocumentCount() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM documents');
    return result.first['count'] as int;
  }
}
