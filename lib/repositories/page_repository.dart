import 'package:smartscan_ai/core/services/database_service.dart';
import 'package:smartscan_ai/models/document_model.dart';

/// Repository for page CRUD operations.
/// Handles page data persistence for document pages.
class PageRepository {
  final DatabaseService _dbService;

  PageRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  /// Retrieves all pages for a document, ordered by page number.
  Future<List<PageModel>> getPages(String documentId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'pages',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'page_number ASC',
    );
    return maps.map((map) => PageModel.fromMap(map)).toList();
  }

  /// Retrieves a single page by ID.
  Future<PageModel?> getPage(String id) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PageModel.fromMap(maps.first);
  }

  /// Inserts a new page.
  Future<void> insertPage(PageModel page) async {
    final db = await _dbService.database;
    await db.insert('pages', page.toMap());
  }

  /// Updates an existing page.
  Future<void> updatePage(PageModel page) async {
    final db = await _dbService.database;
    await db.update(
      'pages',
      page.toMap(),
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  /// Deletes a page by ID.
  Future<void> deletePage(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'pages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all pages for a document.
  Future<void> deleteAllPages(String documentId) async {
    final db = await _dbService.database;
    await db.delete(
      'pages',
      where: 'document_id = ?',
      whereArgs: [documentId],
    );
  }

  /// Reorders pages within a document.
  Future<void> reorderPages(
    String documentId,
    List<String> pageIds,
  ) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      for (int i = 0; i < pageIds.length; i++) {
        await txn.update(
          'pages',
          {'page_number': i + 1},
          where: 'id = ?',
          whereArgs: [pageIds[i]],
        );
      }
    });
  }

  /// Gets the next page number for a document.
  Future<int> getNextPageNumber(String documentId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT MAX(page_number) as max_page FROM pages WHERE document_id = ?',
      [documentId],
    );
    final maxPage = result.first['max_page'] as int?;
    return (maxPage ?? 0) + 1;
  }

  /// Gets the page count for a document.
  Future<int> getPageCount(String documentId) async {
    final db = await _dbService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pages WHERE document_id = ?',
      [documentId],
    );
    return result.first['count'] as int;
  }
}
